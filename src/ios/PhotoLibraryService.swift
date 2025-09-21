import Foundation
import Photos
import UIKit

// MARK: - Data Structures

struct PictureData {
    var data: Data
    var mimeType: String
}

enum PhotoLibraryError: Error, CustomStringConvertible {
    case error(description: String)

    var description: String {
        switch self {
        case .error(let description): return description
        }
    }
}

// MARK: - Service

final class PhotoLibraryService {

    // Singleton expected by PhotoLibrary.swift
    static let instance = PhotoLibraryService()

    private init() { }

    static let PERMISSION_ERROR = "Permission Denial: This application is not allowed to access Photo data."

    // MARK: - Save Video
    func saveVideo(_ url: String, album: String, completion: @escaping (_ libraryItem: NSDictionary?, _ error: String?) -> Void) {
        guard let videoURL = URL(string: url) else {
            completion(nil, "Invalid video URL")
            return
        }

        PHPhotoLibrary.shared().performChanges({
            let request = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: videoURL)
            if let album = PhotoLibraryService.getPhotoAlbum(album) {
                if let placeholder = request?.placeholderForCreatedAsset {
                    let albumChangeRequest = PHAssetCollectionChangeRequest(for: album)
                    albumChangeRequest?.addAssets([placeholder] as NSArray)
                }
            }
        }) { success, error in
            if success {
                completion([:], nil) // minimal OK response
            } else {
                completion(nil, error?.localizedDescription ?? "Unknown error")
            }
        }
    }

    // MARK: - Request Authorization
    func requestAuthorization(_ success: @escaping () -> Void,
                              failure: @escaping (_ err: String) -> Void) {
        let status = PHPhotoLibrary.authorizationStatus()

        if status == .authorized {
            success()
            return
        }

        if status == .notDetermined {
            PHPhotoLibrary.requestAuthorization { newStatus in
                if newStatus == .authorized {
                    success()
                } else {
                    failure("requestAuthorization denied by user")
                }
            }
            return
        }

        failure("Photo access previously denied")
    }

    // MARK: - Helper for album lookup
    fileprivate static func getPhotoAlbum(_ album: String) -> PHAssetCollection? {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", album)
        let fetchResult = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumRegular, options: fetchOptions)
        return fetchResult.firstObject
    }
}

// MARK: - Stubs (so existing plugin methods still compile)

extension PhotoLibraryService {

    func getLibrary(_ options: Any, completion: @escaping ([NSDictionary], Int, Bool) -> Void) {
        completion([], 0, true)
    }

    func getAlbums() -> [NSDictionary] {
        return []
    }

    func getThumbnail(_ photoId: String,
                      thumbnailWidth: Int,
                      thumbnailHeight: Int,
                      quality: Float,
                      completion: @escaping (_ result: PictureData?) -> Void) {
        completion(nil)
    }

    func getPhoto(_ photoId: String,
                  completion: @escaping (_ result: PictureData?) -> Void) {
        completion(nil)
    }

    func getLibraryItem(_ itemId: String,
                        mimeType: String,
                        completion: @escaping (_ base64: String?) -> Void) {
        completion(nil)
    }

    func getVideo(_ videoId: String,
                  completion: @escaping (_ result: PictureData?) -> Void) {
        completion(nil)
    }

    func stopCaching() {
        // no-op
    }

    func saveImage(_ url: String,
                   album: String,
                   completion: @escaping (_ libraryItem: NSDictionary?, _ error: String?) -> Void) {
        completion(nil, "saveImage not implemented")
    }
}