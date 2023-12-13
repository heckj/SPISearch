import SPISearchResult
import XCTest

final class APISearchResponseDecodingTests: XCTestCase {
    // raw response captured 5 dec 2023 from staging.swiftpackageindex.com
    let raw_response = #"""
    {
        "hasMoreResults": false,
        "results": [
            {
                "keyword": {
                    "_0": {
                        "keyword": "keychain-wrapper"
                    }
                }
            },
            {
                "keyword": {
                    "_0": {
                        "keyword": "keychain-access"
                    }
                }
            },
            {
                "keyword": {
                    "_0": {
                        "keyword": "keychain"
                    }
                }
            },
            {
                "keyword": {
                    "_0": {
                        "keyword": "keychainaccess"
                    }
                }
            },
            {
                "package": {
                    "_0": {
                        "packageURL": "/nodes-vapor/keychain",
                        "hasDocs": false,
                        "keywords": [
                            "jwt",
                            "keychain",
                            "server-side-swift",
                            "sikk",
                            "swift",
                            "user-management",
                            "vapor",
                            "vapor-2"
                        ],
                        "packageName": "keychain",
                        "repositoryName": "keychain",
                        "repositoryOwner": "nodes-vapor",
                        "lastActivityAt": "2021-11-08T13:13:23Z",
                        "packageId": "D62CB33F-F4C4-44B0-AC56-5F76979153A0",
                        "stars": 39,
                        "summary": "Easily scaffold a keychain using JWT for Vapor ⛓"
                    }
                }
            },
            {
                "package": {
                    "_0": {
                        "keywords": [
                            "keychain",
                            "swift"
                        ],
                        "hasDocs": false,
                        "repositoryName": "Keychain",
                        "summary": "Swift Keychain utilities.",
                        "packageId": "7BCC58D7-F10A-4ED0-B247-A2DE7233FA6F",
                        "packageURL": "/elegantchaos/Keychain",
                        "stars": 0,
                        "lastActivityAt": "2022-07-08T09:18:06Z",
                        "repositoryOwner": "elegantchaos",
                        "packageName": "Keychain"
                    }
                }
            },
            {
                "package": {
                    "_0": {
                        "repositoryOwner": "AlaskaAirlines",
                        "lastActivityAt": "2020-04-27T17:57:03Z",
                        "keywords": [],
                        "repositoryName": "keychain",
                        "hasDocs": false,
                        "stars": 31,
                        "packageId": "3C0DC429-CE48-4691-ABBA-D79C5A7AA99B",
                        "packageName": "Keychain",
                        "packageURL": "/AlaskaAirlines/keychain",
                        "summary": "Focused subset of Keychain Services in Swift."
                    }
                }
            },
            {
                "package": {
                    "_0": {
                        "packageURL": "/IBM/ios-keychain",
                        "packageId": "21ACE496-CECE-42EF-8FCC-2F31AD4A49AD",
                        "repositoryName": "ios-keychain",
                        "repositoryOwner": "IBM",
                        "keywords": [],
                        "summary": "iOS Keychain Helper ",
                        "hasDocs": false,
                        "lastActivityAt": "2021-07-08T10:25:00Z",
                        "stars": 3,
                        "packageName": "Keychain"
                    }
                }
            },
            {
                "package": {
                    "_0": {
                        "packageURL": "/lipka/Keychain",
                        "keywords": [],
                        "lastActivityAt": "2020-05-30T09:53:36Z",
                        "packageId": "5A63CFC5-A5A7-413D-BA5A-AFFB62BAA691",
                        "repositoryName": "Keychain",
                        "stars": 0,
                        "packageName": "Keychain",
                        "repositoryOwner": "lipka",
                        "hasDocs": false
                    }
                }
            },
            {
                "package": {
                    "_0": {
                        "stars": 6,
                        "hasDocs": false,
                        "packageURL": "/groupeminaste/Keychain.swift",
                        "lastActivityAt": "2021-07-21T10:19:24Z",
                        "packageName": "Keychain",
                        "repositoryName": "Keychain.swift",
                        "summary": "The easiest way to securely store data in the keychain. It's implementation is really close to the UserDefaults.",
                        "keywords": [
                            "keychain",
                            "keychain-wrapper",
                            "spm",
                            "swift"
                        ],
                        "packageId": "D5C44B49-9677-420D-A6AF-D5D6897D4E0F",
                        "repositoryOwner": "groupeminaste"
                    }
                }
            },
            {
                "package": {
                    "_0": {
                        "packageName": "Keychain",
                        "lastActivityAt": "2023-04-07T14:45:44Z",
                        "stars": 0,
                        "packageId": "09A7548B-16E2-4482-B454-6F0F0A692372",
                        "keywords": [
                            "keychain",
                            "keychain-wrapper",
                            "swift"
                        ],
                        "summary": "Swift module for interacting with Keychain via property wrapper",
                        "packageURL": "/tyhopp/keychain",
                        "hasDocs": false,
                        "repositoryOwner": "tyhopp",
                        "repositoryName": "keychain"
                    }
                }
            },
            {
                "package": {
                    "_0": {
                        "packageId": "067E8E63-8A9D-4030-ACFF-A9F55E1DE155",
                        "packageName": "KeychainAccess",
                        "lastActivityAt": "2023-11-12T10:44:55Z",
                        "stars": 7618,
                        "summary": "Simple Swift wrapper for Keychain that works on iOS, watchOS, tvOS and macOS.",
                        "repositoryOwner": "kishikawakatsumi",
                        "repositoryName": "KeychainAccess",
                        "hasDocs": false,
                        "packageURL": "/kishikawakatsumi/KeychainAccess",
                        "keywords": [
                            "keychain",
                            "security",
                            "touch-id"
                        ]
                    }
                }
            },
            {
                "package": {
                    "_0": {
                        "packageURL": "/evgenyneu/keychain-swift",
                        "hasDocs": false,
                        "packageId": "E2300695-5A37-4810-8EE2-58E5E5CA39BE",
                        "repositoryOwner": "evgenyneu",
                        "lastActivityAt": "2023-12-01T23:10:43Z",
                        "repositoryName": "keychain-swift",
                        "stars": 2578,
                        "packageName": "KeychainSwift",
                        "keywords": [
                            "ios",
                            "keychain",
                            "swift"
                        ],
                        "summary": "Helper functions for saving text in Keychain securely for iOS, OS X, tvOS and watchOS."
                    }
                }
            },
            {
                "package": {
                    "_0": {
                        "packageURL": "/auth0/SimpleKeychain",
                        "hasDocs": false,
                        "repositoryOwner": "auth0",
                        "packageId": "FBEDD9B1-9529-482F-9C38-1356266E3689",
                        "repositoryName": "SimpleKeychain",
                        "stars": 502,
                        "packageName": "SimpleKeychain",
                        "lastActivityAt": "2023-10-24T21:10:58Z",
                        "summary": "A simple Keychain wrapper for iOS, macOS, tvOS, and watchOS",
                        "keywords": [
                            "dx-sdk",
                            "ios",
                            "keychain",
                            "security"
                        ]
                    }
                }
            },
            {
                "package": {
                    "_0": {
                        "stars": 3914,
                        "hasDocs": false,
                        "keywords": [
                            "crypto",
                            "face-id",
                            "ios",
                            "keychain",
                            "macos",
                            "security",
                            "touch-id",
                            "tvos",
                            "watchos"
                        ],
                        "repositoryName": "Valet",
                        "packageId": "897CC3BB-693E-4FDA-B6C3-5AAF685E66EE",
                        "repositoryOwner": "square",
                        "lastActivityAt": "2023-09-05T12:28:24Z",
                        "packageName": "Valet",
                        "summary": "Valet lets you securely store data in the iOS, tvOS, or macOS Keychain without knowing a thing about how the Keychain works. It’s easy. We promise.",
                        "packageURL": "/square/Valet"
                    }
                }
            },
            {
                "package": {
                    "_0": {
                        "repositoryName": "Prephirences",
                        "repositoryOwner": "phimage",
                        "packageId": "09AB59CE-ECE0-4406-88B3-A507470E6CD5",
                        "summary": "Prephirences is a Swift library that provides useful protocols and convenience methods to manage application preferences, configurations and app-state. UserDefaults",
                        "stars": 565,
                        "packageURL": "/phimage/Prephirences",
                        "packageName": "Prephirences",
                        "lastActivityAt": "2023-05-23T19:21:45Z",
                        "keywords": [
                            "configuration",
                            "ios",
                            "ios-swift",
                            "keychain",
                            "plist",
                            "preferences",
                            "property-wrapper",
                            "swift",
                            "userdefaults"
                        ],
                        "hasDocs": false
                    }
                }
            },
            {
                "package": {
                    "_0": {
                        "stars": 125,
                        "packageURL": "/omaralbeik/Stores",
                        "lastActivityAt": "2023-07-30T16:43:01Z",
                        "hasDocs": true,
                        "summary": "Typed key-value storage solution to store Codable types in various persistence layers with few lines of code!",
                        "packageName": "Stores",
                        "repositoryName": "Stores",
                        "packageId": "1FB56EF9-8581-442B-9EBE-02DA0505B686",
                        "repositoryOwner": "omaralbeik",
                        "keywords": [
                            "cache",
                            "codable",
                            "coredata",
                            "database",
                            "db",
                            "filesystem",
                            "identifiable",
                            "ios",
                            "keychain",
                            "keyvaluestore",
                            "macos",
                            "spm",
                            "store",
                            "swift",
                            "tvos",
                            "userdefaults",
                            "watchos"
                        ]
                    }
                }
            },
            {
                "package": {
                    "_0": {
                        "keywords": [
                            "certificate-signing-request",
                            "cocoapods",
                            "csr",
                            "elliptic-curve-diffie-hellman",
                            "elliptic-curves",
                            "ios",
                            "keychain",
                            "pki",
                            "privatekey",
                            "publickey",
                            "rsa",
                            "secure-enclave",
                            "swift",
                            "swift-package-manager"
                        ],
                        "repositoryName": "CertificateSigningRequest",
                        "lastActivityAt": "2023-11-26T00:29:41Z",
                        "hasDocs": true,
                        "repositoryOwner": "cbaker6",
                        "packageName": "CertificateSigningRequest",
                        "packageURL": "/cbaker6/CertificateSigningRequest",
                        "summary": "Generate a certificate signing request (CSR) programmatically on iOS/macOS/watchOS/tvOS devices",
                        "stars": 91,
                        "packageId": "E9A5FAB6-29A8-4B07-987F-FE5AF86BEDA8"
                    }
                }
            },
            {
                "package": {
                    "_0": {
                        "packageName": "SwiftKeychainWrapper",
                        "summary": "A simple wrapper for the iOS Keychain to allow you to use it in a similar fashion to User Defaults. Written in Swift.",
                        "packageURL": "/jrendel/SwiftKeychainWrapper",
                        "stars": 1578,
                        "hasDocs": false,
                        "lastActivityAt": "2023-01-10T15:07:30Z",
                        "repositoryOwner": "jrendel",
                        "packageId": "644277AA-F89E-4398-B4A1-4C7306FCCE92",
                        "repositoryName": "SwiftKeychainWrapper",
                        "keywords": []
                    }
                }
            },
            {
                "package": {
                    "_0": {
                        "packageId": "702805ED-DF1B-4C15-9EC7-DE05121D571E",
                        "hasDocs": false,
                        "packageURL": "/alexruperez/SecurePropertyStorage",
                        "repositoryName": "SecurePropertyStorage",
                        "stars": 469,
                        "keywords": [
                            "dependency-injection",
                            "keychain",
                            "property-wrappers",
                            "singleton",
                            "swift",
                            "userdefaults"
                        ],
                        "packageName": "SecurePropertyStorage",
                        "summary": "Helps you define secure storages for your properties using Swift property wrappers.",
                        "lastActivityAt": "2023-05-04T14:58:47Z",
                        "repositoryOwner": "alexruperez"
                    }
                }
            },
            {
                "package": {
                    "_0": {
                        "repositoryOwner": "appoly",
                        "packageURL": "/appoly/PassportKit",
                        "repositoryName": "PassportKit",
                        "keywords": [
                            "ios",
                            "keychain",
                            "laravel",
                            "oauth",
                            "swift",
                            "swift-library"
                        ],
                        "stars": 7,
                        "hasDocs": false,
                        "lastActivityAt": "2023-09-05T13:37:43Z",
                        "packageName": "PassportKit",
                        "packageId": "0CE9867A-FA2D-4D68-9861-0D67D7F90C8A",
                        "summary": "Swift library used for quick and easy authentication using Laravel passport."
                    }
                }
            },
            {
                "package": {
                    "_0": {
                        "packageId": "4FD1B678-DDE7-40F7-BAFA-0AF31597F8E5",
                        "packageName": "SwiftyKeychain",
                        "repositoryName": "SwiftyKeychain",
                        "repositoryOwner": "Machx",
                        "keywords": [],
                        "lastActivityAt": "2023-11-26T22:53:56Z",
                        "packageURL": "/Machx/SwiftyKeychain",
                        "hasDocs": false,
                        "stars": 0,
                        "summary": "Accessing Keychain in Swift for my projects"
                    }
                }
            },
            {
                "package": {
                    "_0": {
                        "packageURL": "/EFPrefix/EFStorage",
                        "keywords": [
                            "dynamicmemberlookup",
                            "hacktoberfest",
                            "keychain",
                            "keychain-access",
                            "keychain-wrapper",
                            "property-wrapper",
                            "propertywrapper",
                            "user-defaults",
                            "userdefaults"
                        ],
                        "summary": "Store anything anywhere with ease. Documentation:",
                        "stars": 9,
                        "hasDocs": false,
                        "lastActivityAt": "2023-03-29T13:40:03Z",
                        "repositoryOwner": "EFPrefix",
                        "packageName": "EFStorage",
                        "packageId": "1233360E-224B-441C-9539-7FBACB2A5BCD",
                        "repositoryName": "EFStorage"
                    }
                }
            },
            {
                "package": {
                    "_0": {
                        "repositoryName": "GoogleAuthentication",
                        "stars": 0,
                        "packageURL": "/Nef10/GoogleAuthentication",
                        "hasDocs": false,
                        "packageName": "GoogleAuthentication",
                        "repositoryOwner": "Nef10",
                        "packageId": "ACC2FA19-6B96-41BA-81F3-7B6DF0340DFA",
                        "summary": "Swift wrapper around OAuthSwift and KeychainAccess to call Google APIs while saving the tokens into keychain",
                        "keywords": [
                            "googleauthentication",
                            "keychainaccess",
                            "oauthswift"
                        ],
                        "lastActivityAt": "2023-12-04T06:38:23Z"
                    }
                }
            },
            {
                "package": {
                    "_0": {
                        "packageId": "45990E8D-7B83-4081-BE1C-704C4908656E",
                        "packageURL": "/futuredapp/FTPropertyWrappers",
                        "summary": "Property wrappers for User Defaults, Keychain, StoredSubject and synchronization.",
                        "repositoryName": "FTPropertyWrappers",
                        "packageName": "FTPropertyWrappers",
                        "lastActivityAt": "2021-09-20T14:02:08Z",
                        "hasDocs": false,
                        "keywords": [
                            "keychain",
                            "property-wrapper",
                            "swift",
                            "swift5-1"
                        ],
                        "stars": 8,
                        "repositoryOwner": "futuredapp"
                    }
                }
            },
            {
                "package": {
                    "_0": {
                        "packageId": "D5CEFC1E-2F71-4BB2-BE5D-B1D462EA7693",
                        "hasDocs": false,
                        "repositoryOwner": "objcio",
                        "summary": "Keychain Item Property Wrapper",
                        "packageURL": "/objcio/keychain-item",
                        "keywords": [],
                        "repositoryName": "keychain-item",
                        "lastActivityAt": "2019-11-13T12:36:59Z",
                        "packageName": "KeychainItem",
                        "stars": 38
                    }
                }
            },
            {
                "package": {
                    "_0": {
                        "keywords": [
                            "keychain",
                            "keychain-wrapper",
                            "password",
                            "security",
                            "swift"
                        ],
                        "repositoryName": "StealthyStash",
                        "repositoryOwner": "brightdigit",
                        "summary": "A Swifty database interface into the Keychain Services.",
                        "packageURL": "/brightdigit/StealthyStash",
                        "stars": 7,
                        "lastActivityAt": "2023-06-17T01:15:27Z",
                        "hasDocs": false,
                        "packageId": "290C1351-7688-4149-BE67-43A8FAEE2991",
                        "packageName": "StealthyStash"
                    }
                }
            },
            {
                "package": {
                    "_0": {
                        "packageURL": "/JuanjoArreola/KeychainStore",
                        "keywords": [
                            "keychain",
                            "swift"
                        ],
                        "repositoryOwner": "JuanjoArreola",
                        "repositoryName": "KeychainStore",
                        "stars": 6,
                        "packageName": "KeychainStore",
                        "hasDocs": false,
                        "summary": "Swift 5 Framework to access the Keychain in iOS",
                        "packageId": "43027C78-2D77-4C7F-892A-EE564749DA53",
                        "lastActivityAt": "2021-09-26T18:38:18Z"
                    }
                }
            },
            {
                "package": {
                    "_0": {
                        "lastActivityAt": "2023-10-22T22:20:21Z",
                        "stars": 4,
                        "repositoryOwner": "FelixHerrmann",
                        "packageName": "FHPropertyWrappers",
                        "summary": "Some useful Swift Property Wrappers.",
                        "packageURL": "/FelixHerrmann/FHPropertyWrappers",
                        "repositoryName": "FHPropertyWrappers",
                        "keywords": [
                            "keychain",
                            "property-wrapper",
                            "swift",
                            "userdefaults"
                        ],
                        "hasDocs": false,
                        "packageId": "34DBAF3C-0558-4D90-8CF6-4820F1BD2952"
                    }
                }
            },
            {
                "package": {
                    "_0": {
                        "repositoryName": "PersistedProperty",
                        "hasDocs": false,
                        "keywords": [
                            "keychain",
                            "persistable",
                            "persistence",
                            "properties",
                            "property-wrapper",
                            "storage",
                            "user-defaults"
                        ],
                        "packageURL": "/danielepantaleone/PersistedProperty",
                        "packageId": "857A57A0-D160-43D5-A127-B054587E8B40",
                        "packageName": "PersistedProperty",
                        "repositoryOwner": "danielepantaleone",
                        "summary": "A lightweight framework to persist iOS properties written in Swift",
                        "lastActivityAt": "2023-10-31T08:23:08Z",
                        "stars": 2
                    }
                }
            },
            {
                "package": {
                    "_0": {
                        "hasDocs": false,
                        "keywords": [],
                        "summary": "A Keychain wrapper allowing safe interaction with Keychain using strongly typed values and even in Swift concurrency fashion.",
                        "packageName": "SwiftKeychain",
                        "repositoryName": "SwiftKeychain",
                        "repositoryOwner": "ShenghaiWang",
                        "packageId": "E36406E4-F38A-4941-AB76-9EAB96D35836",
                        "packageURL": "/ShenghaiWang/SwiftKeychain",
                        "stars": 2,
                        "lastActivityAt": "2023-07-11T02:41:31Z"
                    }
                }
            },
            {
                "package": {
                    "_0": {
                        "repositoryOwner": "trifork",
                        "packageURL": "/trifork/TIMEncryptedStorage-iOS",
                        "packageId": "74C3A384-F6F6-48F9-90B9-3F1F5F81595A",
                        "packageName": "TIMEncryptedStorage",
                        "repositoryName": "TIMEncryptedStorage-iOS",
                        "stars": 2,
                        "lastActivityAt": "2022-03-04T10:47:07Z",
                        "hasDocs": false,
                        "summary": "iOS framework for KeyService feature of Trifork Identity Manager. The purpose of this framework is to encrypt and decrypt data based on a user provided secret or with biometrics. The framework exchanges secrets for encryption keys in safe way and stores encrypted data in the Keychain.",
                        "keywords": [
                            "aes",
                            "biometrics",
                            "decryption",
                            "encryption",
                            "keychain",
                            "trifork-identity-manager"
                        ]
                    }
                }
            },
            {
                "package": {
                    "_0": {
                        "packageName": "Haversack",
                        "hasDocs": false,
                        "stars": 1,
                        "repositoryName": "Haversack",
                        "lastActivityAt": "2023-10-12T17:35:56Z",
                        "packageId": "E736C261-8545-4859-A19C-C2B6AC94EF5F",
                        "summary": "A Swift library for keychain access on Apple devices",
                        "keywords": [
                            "ios",
                            "keychain",
                            "macos",
                            "swift",
                            "tvos",
                            "watchos"
                        ],
                        "packageURL": "/jamf/Haversack",
                        "repositoryOwner": "jamf"
                    }
                }
            },
            {
                "package": {
                    "_0": {
                        "hasDocs": false,
                        "summary": "A Keychain access wrapper in Swift, because the world needs more of these",
                        "keywords": [
                            "ios",
                            "keychain",
                            "macos",
                            "swift",
                            "watchos"
                        ],
                        "packageId": "73F97109-3720-4E7A-B52A-3276C24649FC",
                        "packageURL": "/ptsochantaris/key-vine",
                        "repositoryOwner": "ptsochantaris",
                        "repositoryName": "key-vine",
                        "stars": 0,
                        "packageName": "KeyVine",
                        "lastActivityAt": "2023-08-16T14:52:37Z"
                    }
                }
            },
            {
                "package": {
                    "_0": {
                        "stars": 0,
                        "packageURL": "/William-Weng/WWKeychain",
                        "hasDocs": false,
                        "packageName": "WWKeychain",
                        "lastActivityAt": "2023-09-28T03:46:27Z",
                        "repositoryName": "WWKeychain",
                        "summary": "Use the \"property wrapper\" to make an enhanced version of Keychain, so that Keychain can be as convenient as UserDefaults.",
                        "keywords": [],
                        "repositoryOwner": "William-Weng",
                        "packageId": "3E853D66-06AC-458F-8457-E4DCBF204DDA"
                    }
                }
            },
            {
                "package": {
                    "_0": {
                        "repositoryOwner": "CaptureContext",
                        "packageId": "FC260A29-DA3F-4400-ACAD-8557F3257878",
                        "stars": 37,
                        "lastActivityAt": "2022-01-07T00:15:27Z",
                        "summary": "Client declarations and live implementations for standard iOS managers",
                        "keywords": [
                            "analytics",
                            "caching",
                            "clients",
                            "functional-programming",
                            "idfa",
                            "interfaces",
                            "ios",
                            "keychain",
                            "macos",
                            "managers",
                            "notifications",
                            "protocol-witnesses",
                            "swift",
                            "tvos",
                            "userdefaults",
                            "watchos"
                        ],
                        "packageName": "swift-standard-clients",
                        "packageURL": "/CaptureContext/swift-standard-clients",
                        "repositoryName": "swift-standard-clients",
                        "hasDocs": false
                    }
                }
            },
            {
                "package": {
                    "_0": {
                        "packageURL": "/danielctull/KeychainItem",
                        "hasDocs": false,
                        "stars": 3,
                        "keywords": [
                            "keychain",
                            "swift",
                            "swift-package-manager"
                        ],
                        "packageId": "4BBEBBB3-55C7-4F8F-AC4E-08682A7FEE3C",
                        "repositoryOwner": "danielctull",
                        "lastActivityAt": "2022-11-23T08:25:20Z",
                        "repositoryName": "KeychainItem",
                        "packageName": "KeychainItem"
                    }
                }
            },
            {
                "package": {
                    "_0": {
                        "stars": 3,
                        "packageId": "F281908C-EB84-42BC-B9E9-71075B6B2B39",
                        "packageURL": "/binaryscraping/swift-composable-keychain",
                        "repositoryOwner": "binaryscraping",
                        "hasDocs": false,
                        "keywords": [
                            "composable-architecture",
                            "keychain",
                            "swift",
                            "tca"
                        ],
                        "repositoryName": "swift-composable-keychain",
                        "packageName": "ComposableKeychain",
                        "summary": "A composable keychain wrapper around https://github.com/kishikawakatsumi/KeychainAccess",
                        "lastActivityAt": "2022-09-05T12:42:10Z"
                    }
                }
            },
            {
                "package": {
                    "_0": {
                        "lastActivityAt": "2021-04-08T13:34:20Z",
                        "summary": "A modern wrapper for iOS, macOS, tvOS and watchOS Keychain.",
                        "packageId": "BF78B867-FDB0-4BAD-B798-74DEEBBA2862",
                        "repositoryOwner": "sbertix",
                        "keywords": [],
                        "packageName": "Swiftchain",
                        "hasDocs": false,
                        "packageURL": "/sbertix/Swiftchain",
                        "repositoryName": "Swiftchain",
                        "stars": 2
                    }
                }
            },
            {
                "package": {
                    "_0": {
                        "stars": 0,
                        "packageURL": "/beMappy/Mappy-KeychainAccess",
                        "keywords": [],
                        "repositoryOwner": "beMappy",
                        "lastActivityAt": "2023-06-23T09:24:01Z",
                        "summary": "XCFramework version of KeychainAccess (https://github.com/kishikawakatsumi/KeychainAccess)",
                        "packageName": "KeychainAccess",
                        "repositoryName": "Mappy-KeychainAccess",
                        "hasDocs": false,
                        "packageId": "A1A96E9A-F933-431C-989C-8E64DAFDC8F3"
                    }
                }
            }
        ],
        "searchTerm": "keychain",
        "searchFilters": []
    }
    """#

    func testDecodingAPISearchResponse() async throws {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let raw_data = try XCTUnwrap(raw_response.data(using: .utf8))
        let results = try decoder.decode(SwiftPackageIndexAPI.SearchResponse.self, from: raw_data)
        // dump(results)
        XCTAssertEqual(results.results.count, 40)
    }

    func testStoredConvertedExamples() async throws {
        XCTAssertEqual(SearchResult.exampleCollection.count, 3)
    }
}
