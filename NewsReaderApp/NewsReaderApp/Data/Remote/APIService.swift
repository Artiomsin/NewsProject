import Foundation

class APIService {
    private let apiKey = "c604c88fe77347b88253d15fc96ec245"
    private let baseURL = "https://newsapi.org/v2/everything"
    
    func fetchNews(query: String, fromDate: String, sortBy: String, completion: @escaping (Result<[News], Error>) -> Void) {
        let urlString = "\(baseURL)?q=\(query)&from=\(fromDate)&sortBy=\(sortBy)&apiKey=\(apiKey)"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 400)))
            return
        }
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(NSError(domain: "No Data", code: 404)))
                return
            }
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let response = try decoder.decode(NewsResponseDTO.self, from: data)
                print("\n✅ Decoded News Response:")
                print("Articles count: \(response.articles.count)")
                print("--------------------------------------------------")
                for (index, article) in response.articles.enumerated() {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "MMM d, yyyy, h:mm a"
                    let formattedDate = dateFormatter.string(from: article.publishedAt)
                    print("""
                    📰 Article \(index + 1):
                    Title: \(article.title)
                    Description: \(article.description ?? "No description")
                    Source: \(article.source.name)
                    URL to Image: \(article.urlToImage ?? "No image URL")
                    Published At: \(formattedDate)
                    URL: \(article.url ?? "No URL")
                    Content: \(article.content ?? "No content")
                    --------------------------------------------------
                    """)
                }
                completion(.success(response.articles))
            } catch {
                print("❌ JSON Decoding Error: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }.resume()
    }
}
