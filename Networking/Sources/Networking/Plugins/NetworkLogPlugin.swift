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
        
        if let httpResponse = response as? HTTPURLResponse {
            output.append("Code: \(httpResponse.statusCode)\(separator)")
        }
        
        if let data = data, let prettyPrinted = self.prettyPrintedJSONString(from: data) {
            output.append("Response:\(separator)\(prettyPrinted)")
        }
        
        output.append(separator)
        
        return output
    }
    
    func prettyPrintedJSONString(from data: Data) -> NSString? {
        
        guard let object = try? JSONSerialization.jsonObject(with: data, options: []),
            let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
            let prettyPrintedString = NSString(data: data, encoding: String.Encoding.utf8.rawValue) else { return nil }
        
        return prettyPrintedString
    }
}
