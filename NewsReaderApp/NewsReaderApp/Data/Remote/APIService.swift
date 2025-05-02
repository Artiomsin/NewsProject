import Foundation

enum NetworkError: Error {
    case noInternet
    case timeout
    case invalidResponse
    case serverError(statusCode: Int)
    case emptyData
    case decodingFailed
    case other(Error)
}

import Foundation

class APIService {
    private let apiKey = "c604c88fe77347b88253d15fc96ec245"
    private let baseURL = "https://newsapi.org/v2/everything"
    
    func fetchNews(query: String, fromDate: String, sortBy: String, completion: @escaping (Result<[News], NetworkError>) -> Void) {
        let urlString = "\(baseURL)?q=\(query)&from=\(fromDate)&sortBy=\(sortBy)&apiKey=\(apiKey)"
        guard let url = URL(string: urlString) else {
            completion(.failure(.invalidResponse))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            
            if let error = error {
                if let urlError = error as? URLError {
                    switch urlError.code {
                    case .notConnectedToInternet:
                        completion(.failure(.noInternet))
                    case .timedOut:
                        completion(.failure(.timeout))
                    default:
                        completion(.failure(.other(error)))
                    }
                } else {
                    completion(.failure(.other(error)))
                }
                return
            }
            
            guard let data = data else {
                completion(.failure(.emptyData))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.invalidResponse))
                return
            }
            
            if httpResponse.statusCode < 200 || httpResponse.statusCode >= 300 {
                completion(.failure(.serverError(statusCode: httpResponse.statusCode)))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let response = try decoder.decode(NewsResponseDTO.self, from: data)
                
                print("\n Decoded News Response:")
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
                completion(.failure(.decodingFailed))
            }
        }.resume()
    }
}



