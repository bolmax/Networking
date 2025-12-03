//
//  NetworkLogPlugin.swift
//  
//
//  Created by Tsahi Deri on 11/06/2020.
//

import Foundation
import Moya

public class NetworkLogPlugin: PluginType {
    
    private let dateFormatString = "dd/MM/yyyy HH:mm:ss"
    private let dateFormatter = DateFormatter()
    private let separator = "\n"
    
    private var startDate: Date?

    public init() {}
    
    public func willSend(_ request: Moya.RequestType, target: TargetType) {
        startDate = Date()
        output(message: logNetworkRequest(request.request as URLRequest?))
    }
    
    public func didReceive(_ result: Result<Moya.Response, MoyaError>, target: TargetType) {
        if case .success(let response) = result {
            output(message: logNetworkResponse(response.response, data: response.data, target: target))
        } else {
            output(message: logNetworkResponse(nil, data: nil, target: target))
        }
        guard let startDate = startDate else { return }
        output(message: "The request took \(Date().timeIntervalSince(startDate)) seconds.")
    }
    
    private func output(message: String) {
        print(message)
    }
}

private extension NetworkLogPlugin {
    
    var date: String {
        dateFormatter.dateFormat = dateFormatString
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        return dateFormatter.string(from: Date())
    }
    
    func logNetworkRequest(_ request: URLRequest?) -> String {
        
        var output = String()
        
        guard let request = request else {
            return output
        }
        
        output.append("\(separator)[\(date)]\(separator)")
        
        if let url = request.url {
            output.append("URL: \(url)\(separator)")
        }
        
        if let httpMethod = request.httpMethod {
            output.append("HTTP Method: \(httpMethod)\(separator)")
        }
        
        if let allHTTPHeaderFields = request.allHTTPHeaderFields {
            output.append("HTTP Headers:\(separator)\(allHTTPHeaderFields)\(separator)")
        }

        if let httpBody = request.httpBody, let bodyString = String(data: httpBody, encoding: .utf8) {
            output.append("HTTP Body:\(separator)\(bodyString)")
        }
        
        output.append(separator)
        
        return output
    }
    
    func logNetworkResponse(_ response: URLResponse?, data: Data?, target: TargetType) -> String {
        
        var output = String()
        output.append("\(separator)[\(date)]\(separator)")
        output.append("URL: \(target.baseURL.absoluteString)\(target.path)\(separator)")
        
        // MARK: - HTTP Info
        if let httpResponse = response as? HTTPURLResponse {
            output.append("HTTP Status Code: \(httpResponse.statusCode)\(separator)")
        }
        
        // MARK: - No Data
        guard let data = data else {
            output.append("HTTP Response: <No data>\(separator)")
            return output
        }
        
        // MARK: - JSON Pretty Print Attempt
        let pretty = prettyPrintedJSONString(from: data) // (string, error)
        
        if let json = pretty.string {
            output.append("HTTP Response (JSON):\(separator)\(json)\(separator)")
            return output
        }
        if let jsonError = pretty.error {
            output.append("JSON parse error: \(jsonError.localizedDescription)\(separator)")
        }
        
        // MARK: - UTF-8 Fallback
        if let utf8 = String(data: data, encoding: .utf8) {
            output.append("Response (UTF-8):\(separator)\(utf8)\(separator)")
            return output
        }
        
        // MARK: - Raw Bytes Fallback
        output.append("Response: <binary or invalid UTF-8>\(separator)")
        output.append("Raw bytes: \(data as NSData)\(separator)")
        
        return output
    }
    
    func prettyPrintedJSONString(from data: Data) -> (string: String?, error: Error?) {
        do {
            let object = try JSONSerialization.jsonObject(with: data, options: [])
            let prettyData = try JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted])

            if let string = String(data: prettyData, encoding: .utf8) {
                return (string, nil)
            } else {
                return (
                    nil,
                    NSError(
                        domain: "PrettyPrint",
                        code: 2,
                        userInfo: [NSLocalizedDescriptionKey: "UTF-8 encoding failed"]
                    )
                )
            }
        } catch {
            return (nil, error)
        }
    }
}
