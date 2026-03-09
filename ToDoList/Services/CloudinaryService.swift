//
//  CloudinaryService.swift
//  ToDoList
//
//  Created by Jollibe Dablo - INTERN on 3/6/26.
//

import Foundation
import UIKit
import CryptoKit

/// Actor handling Cloudinary image upload operations
actor CloudinaryService {
    // MARK: - Singleton
    
    static let shared = CloudinaryService()
    
    private init() {}
    
    // MARK: - Properties
    
    private let cloudName = "dn6rffrwk"
    private let apiKey = "344196553561727"
    private let apiSecret = "MbHFiTcNa__FPmA87l8Ey_Sqo4w"
    private let uploadPreset = "todolist_unsigned"
    
    // MARK: - Upload Methods

    func uploadImage(_ image: UIImage) async throws -> String {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw CloudinaryError.invalidImage
        }
        
        let url = URL(string: "https://api.cloudinary.com/v1_1/\(cloudName)/image/upload")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 30
        
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        
        // Add upload preset (for unsigned upload)
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"upload_preset\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(uploadPreset)\r\n".data(using: .utf8)!)
        
        // Add folder
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"folder\"\r\n\r\n".data(using: .utf8)!)
        body.append("profile_photos\r\n".data(using: .utf8)!)
        
        // Add image file
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"profile.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        
        // Close boundary
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw CloudinaryError.invalidResponse
            }
            
            // Log response for debugging
            if let responseString = String(data: data, encoding: .utf8) {
                print("Cloudinary Response (\(httpResponse.statusCode)): \(responseString)")
            }
            
            guard httpResponse.statusCode == 200 else {
                // Try to parse error message
                if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let error = json["error"] as? [String: Any],
                   let message = error["message"] as? String {
                    throw CloudinaryError.uploadFailedWithMessage(message)
                }
                throw CloudinaryError.uploadFailed(statusCode: httpResponse.statusCode)
            }
            
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            
            guard let secureUrl = json?["secure_url"] as? String else {
                throw CloudinaryError.invalidResponse
            }
            
            return secureUrl
        } catch let error as CloudinaryError {
            throw error
        } catch {
            throw CloudinaryError.networkError(error)
        }
    }
    
    /// Upload an image using signed upload (alternative method)
    func uploadImageSigned(_ image: UIImage) async throws -> String {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw CloudinaryError.invalidImage
        }
        
        let url = URL(string: "https://api.cloudinary.com/v1_1/\(cloudName)/image/upload")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 30
        
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        
        let timestamp = String(Int(Date().timeIntervalSince1970))
        let folder = "profile_photos"
        
        // Create signature string (alphabetically ordered)
        let paramsToSign = [
            "folder": folder,
            "timestamp": timestamp
        ]
        
        let sortedParams = paramsToSign.sorted { $0.key < $1.key }
        let signatureString = sortedParams.map { "\($0.key)=\($0.value)" }.joined(separator: "&") + apiSecret
        let signature = signatureString.sha1()
        
        print("Signature String: \(signatureString)")
        print("Signature: \(signature)")
        
        // Add file
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"profile.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        
        // Add API key
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"api_key\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(apiKey)\r\n".data(using: .utf8)!)
        
        // Add timestamp
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"timestamp\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(timestamp)\r\n".data(using: .utf8)!)
        
        // Add folder
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"folder\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(folder)\r\n".data(using: .utf8)!)
        
        // Add signature
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"signature\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(signature)\r\n".data(using: .utf8)!)
        
        // Close boundary
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw CloudinaryError.invalidResponse
            }
            
            // Log response for debugging
            if let responseString = String(data: data, encoding: .utf8) {
                print("Cloudinary Response (\(httpResponse.statusCode)): \(responseString)")
            }
            
            guard httpResponse.statusCode == 200 else {
                if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let error = json["error"] as? [String: Any],
                   let message = error["message"] as? String {
                    throw CloudinaryError.uploadFailedWithMessage(message)
                }
                throw CloudinaryError.uploadFailed(statusCode: httpResponse.statusCode)
            }
            
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            
            guard let secureUrl = json?["secure_url"] as? String else {
                throw CloudinaryError.invalidResponse
            }
            
            return secureUrl
        } catch let error as CloudinaryError {
            throw error
        } catch {
            throw CloudinaryError.networkError(error)
        }
    }
    
    /// Delete an image from Cloudinary (optional - requires authentication)
    /// - Parameter publicId: The public ID of the image to delete
    func deleteImage(publicId: String) async throws {
        // Note: Deletion requires admin API access
        // For now, we'll just clear the reference in the app
        // Implement if needed with proper backend authentication
    }
}

// MARK: - Errors

enum CloudinaryError: LocalizedError {
    case invalidImage
    case invalidResponse
    case uploadFailed(statusCode: Int)
    case uploadFailedWithMessage(String)
    case networkError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidImage:
            return "The image format is invalid"
        case .invalidResponse:
            return "Invalid response from server"
        case .uploadFailed(let statusCode):
            return "Upload failed with status code: \(statusCode)"
        case .uploadFailedWithMessage(let message):
            return "Upload failed: \(message)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
}

// MARK: - String SHA1 Extension

extension String {
    nonisolated func sha1() -> String {
        let data = Data(self.utf8)
        let hash = Insecure.SHA1.hash(data: data)
        return hash.map { String(format: "%02hhx", $0) }.joined()
    }
}
