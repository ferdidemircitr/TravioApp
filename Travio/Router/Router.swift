//
//  Router.swift
//  Travio
//
//  Created by Ferdi DEMİRCİ on 31.08.2023.
//

import Foundation
import Alamofire

public enum Router: URLRequestConvertible {
    
    case login(parameters: Parameters)
    case signIn(parameters: Parameters)
    case placeById(placeId: String)
    case allPlaces
    case deletePlace(placeId: String)
    case allGalleryByPlaceId(placeId: String)
    case createVisit(parameters: Parameters)
    case allVisit
    case createPlace(parameters: Parameters)
    case createGallery(parameters: Parameters)
    case upload(image: [Data])
    case getVisitByPlaceId(placeId: String)
    case deleteVisitById(visitId: String)
    case popularPlaces(limit: Int?)
    case lastPlaces(limit: Int?)
    case user
    case editProfile(parameters: Parameters)
    case changePassword(parameters: Parameters)
    case getAllPlacesForUser
    case me
    case refreshToken(parameters: Parameters)

    
    var accessToken: String {
        guard let accessToken = KeychainManager.shared.getValue(forKey: "accessTokenKey") else { return "" }
        return accessToken
    }
    
    var baseURL: URL {
        return URL(string: "https://api.iosclass.live")!
    }
    
    private var method: HTTPMethod {
        switch self {
        case .login, .signIn, .createVisit, .createPlace, .createGallery, .upload, .refreshToken:
            return .post
        case .placeById, .allPlaces, .allGalleryByPlaceId, .allVisit, .getVisitByPlaceId, .popularPlaces, .lastPlaces, .user, .getAllPlacesForUser, .me:
            return .get
        case .deleteVisitById, .deletePlace:
            return .delete
        case .editProfile, .changePassword:
            return .put
        }
    }
    
    var path: String {
        switch self {
        case .login:
            return "/v1/auth/login"
        case .signIn:
            return "/v1/auth/register"
        case .placeById(let placeId):
            return "/v1/galleries/\(placeId)"
        case .allPlaces:
            return "/v1/places"
        case .deletePlace(let placeId):
            return "/v1/places/\(placeId)"
        case .allGalleryByPlaceId(let placeId):
            return "/v1/galleries/\(placeId)"
        case .createVisit, .allVisit:
            return "/v1/visits"
        case .createPlace:
            return "/v1/places"
        case .createGallery:
            return "/v1/galleries"
        case .upload:
            return "/upload"
        case .getVisitByPlaceId(let placeId):
            return "/v1/visits/user/\(placeId)"
        case .deleteVisitById(let visitId):
            return "/v1/visits/\(visitId)"
        case .popularPlaces:
            return "/v1/places/popular"
        case .lastPlaces:
            return "/v1/places/last"
        case .user:
            return "v1/me"
        case .editProfile:
            return "v1/edit-profile"
        case .changePassword:
            return "v1/change-password"
        case .getAllPlacesForUser:
            return "/v1/places/user"
        case .me:
            return "v1/me"
        case .refreshToken:
            return "/v1/auth/refresh"
        }
    }
    
    private var parameters: Parameters {
        switch self {
        case .login(let parameters), .signIn(let parameters), .createVisit(let parameters), .createPlace(let parameters), .createGallery(let parameters), .editProfile(let parameters), .changePassword(let parameters), .refreshToken(let parameters):
            return parameters
        case .popularPlaces(let limit), .lastPlaces(let limit):
            var params: Parameters = [:]
            if let limit = limit {
                params["limit"] = limit
            }
            return params
        case .placeById, .allPlaces, .deletePlace, .allGalleryByPlaceId, .allVisit, .upload, .getVisitByPlaceId, .deleteVisitById, .user, .getAllPlacesForUser, .me:
            return [:]
        }
    }
    
    private var headers: HTTPHeaders {
        switch self {
        case .login, .signIn, .allPlaces, .allGalleryByPlaceId, .popularPlaces, .lastPlaces, .refreshToken:
            return [:]
        case .placeById, .createVisit, .allVisit, .createPlace, .createGallery, .getVisitByPlaceId, .deleteVisitById, .deletePlace, .user, .editProfile, .changePassword, .getAllPlacesForUser, .me:
            return ["Authorization": "Bearer \(accessToken)"]
        case .upload:
            return ["Content-Type": "multipart/form-data"]
        }
    }
    
    var multipartFormData: MultipartFormData {
        let formData = MultipartFormData()
        switch self {
        case .upload(let imageData):
            imageData.forEach { image in
                formData.append(image, withName: "file", fileName: "image.jpg", mimeType: "image/jpeg")
            }
            return formData
        default:
            break
        }
        return formData
    }
    
    
    public func asURLRequest() throws -> URLRequest {
        let url = try baseURL.asURL()
        var urlRequest = URLRequest(url: url.appendingPathComponent(path))
        urlRequest.httpMethod = method.rawValue
        urlRequest.headers = headers
        
        let encoding: ParameterEncoding = {
        switch method {
        case .get:
            return URLEncoding.default
        default:
            return JSONEncoding.default
        }
    }()
    return try encoding.encode(urlRequest, with: parameters)
    }
}
