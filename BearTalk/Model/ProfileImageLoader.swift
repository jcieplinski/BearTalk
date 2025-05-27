import SwiftUI

actor ProfileImageLoader {
    static let shared = ProfileImageLoader()
    private var cache: [URL: UIImage] = [:]
    private var loadingTasks: [URL: Task<UIImage?, Error>] = [:]
    private let fileManager = FileManager.default
    private let cacheDirectory: URL
    
    private let session: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 8
        config.timeoutIntervalForResource = 8
        config.waitsForConnectivity = true
        config.requestCachePolicy = .returnCacheDataElseLoad
        // Disable QUIC/HTTP3 to use HTTP/1.1 or HTTP/2
        config.connectionProxyDictionary = [
            kCFProxyHostNameKey: "disable-quic",
            kCFProxyPortNumberKey: 0
        ]
        return URLSession(configuration: config)
    }()
    
    private init() {
        // Set up cache directory
        let cachesDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        cacheDirectory = cachesDirectory.appendingPathComponent("ProfileImages", isDirectory: true)
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        
        // Start prefetching if we have a cached URL
        Task {
            await prefetchCachedImages()
        }
    }
    
    private func prefetchCachedImages() async {
        guard let urls = try? fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: nil) else { return }
        
        for url in urls {
            guard let data = try? Data(contentsOf: url),
                  let image = UIImage(data: data) else { continue }
            
            // Create a URL from the filename
            if let originalURL = URL(string: "https://cdns.gigya.com/photos/\(url.deletingPathExtension().lastPathComponent)") {
                cache[originalURL] = image
                print("Prefetched image from disk cache: \(originalURL)")
            }
        }
    }
    
    private func cacheFilePath(for url: URL) -> URL {
        // Use a more reliable filename based on the photo ID
        let components = url.pathComponents
        if let photoId = components.last?.split(separator: ".").first {
            return cacheDirectory.appendingPathComponent(String(photoId))
        }
        return cacheDirectory.appendingPathComponent(url.lastPathComponent)
    }
    
    private func loadFromDisk(url: URL) -> UIImage? {
        let filePath = cacheFilePath(for: url)
        guard let data = try? Data(contentsOf: filePath),
              let image = UIImage(data: data) else {
            return nil
        }
        print("Retrieved image from disk cache: \(url)")
        return image
    }
    
    private func saveToDisk(url: URL, image: UIImage) {
        let filePath = cacheFilePath(for: url)
        if let data = image.jpegData(compressionQuality: 0.8) {
            try? data.write(to: filePath)
            print("Saved image to disk cache: \(url)")
        }
    }
    
    func loadImage(from urlString: String) async throws -> UIImage? {
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        // Check memory cache first
        if let cachedImage = cache[url] {
            print("Retrieved image from memory cache: \(url)")
            return cachedImage
        }
        
        // Check disk cache
        if let diskImage = loadFromDisk(url: url) {
            cache[url] = diskImage // Add to memory cache
            return diskImage
        }
        
        // Check if there's already a loading task
        if let existingTask = loadingTasks[url] {
            return try await existingTask.value
        }
        
        // Create new loading task
        let task = Task<UIImage?, Error> {
            defer {
                loadingTasks[url] = nil
            }
            
            do {
                // Single attempt with a fresh request
                let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 8)
                let (data, response) = try await session.data(for: request)
                
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    throw URLError(.badServerResponse)
                }
                
                guard let image = UIImage(data: data) else {
                    throw URLError(.cannotDecodeContentData)
                }
                
                // Cache the image in memory and on disk
                cache[url] = image
                saveToDisk(url: url, image: image)
                print("Successfully loaded and cached image: \(url)")
                return image
            } catch {
                print("Error loading image: \(error.localizedDescription)")
                throw error
            }
        }
        
        loadingTasks[url] = task
        return try await task.value
    }
    
    func clearCache() {
        cache.removeAll()
        try? fileManager.removeItem(at: cacheDirectory)
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }
}

struct ProfileImageView: View {
    let photoUrl: String
    @State private var image: UIImage?
    @State private var retryCount = 0
    @State private var isLoading = true
    @State private var loadError = false
    
    private let maxRetries = 3
    
    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .clipShape(Circle())
            } else if loadError && retryCount >= maxRetries {
                Image(systemName: "person.circle")
                    .font(.title2)
            } else {
                ProgressView()
                    .frame(width: 24, height: 24)
                    .task {
                        await loadImage()
                    }
            }
        }
    }
    
    private func loadImage() async {
        guard !loadError || retryCount < maxRetries else { return }
        
        do {
            image = try await ProfileImageLoader.shared.loadImage(from: photoUrl)
            isLoading = false
            loadError = false
        } catch {
            print("Failed to load profile image: \(error.localizedDescription)")
            if retryCount < maxRetries {
                let delay = pow(2.0, Double(retryCount))
                print("Retrying profile image load (attempt \(retryCount + 1) of \(maxRetries)) after \(delay) seconds")
                try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                retryCount += 1
                await loadImage()
            } else {
                print("Max retries reached for profile image load")
                loadError = true
            }
        }
    }
} 