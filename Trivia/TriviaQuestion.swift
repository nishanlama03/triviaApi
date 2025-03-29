//
//  TriviaQuestion.swift
//  Trivia
//
//  Created by Mari Batilando on 4/6/23.
//

import Foundation

extension String {
    var htmlDecoded: String {
        guard let data = self.data(using: .utf8) else { return self }
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        if let attributedString = try? NSAttributedString(data: data, options: options, documentAttributes: nil) {
            return attributedString.string
        }
        return self
    }
}

struct TriviaQuestion: Decodable {
  let category: String
  let question: String
  let correctAnswer: String
  let incorrectAnswers: [String]
    enum CodingKeys: String, CodingKey {
            case category, question
            case correctAnswer = "correct_answer"
            case incorrectAnswers = "incorrect_answers"
        }
}

struct TriviaResponse: Decodable {
    let results: [TriviaQuestion]
}

class TriviaQuestionService {
    static func fetchQuestions(amount: Int = 5, completion: @escaping ([TriviaQuestion]?) -> Void) {
        let urlString = "https://opentdb.com/api.php?amount=\(amount)&type=multiple"
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }

            do {
                let decoder = JSONDecoder()
                let triviaResponse = try decoder.decode(TriviaResponse.self, from: data)
                completion(triviaResponse.results)
            } catch {
                print("Error decoding: \(error)")
                completion(nil)
            }
        }.resume()
    }
}
