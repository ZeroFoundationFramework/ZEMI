//
//  DBClientErrors.swift
//  ZEMI
//
//  Created by Philipp Kotte on 28.07.25.
//


enum DBClientErrors: Error {
    case serverVersionNotFound
    case connectionIdNotFound
    case bufferToShort
    case lengthZero
    case returningLengthZero
    case authPluginNameNotFound
}
