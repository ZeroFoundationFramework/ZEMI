enum DBClientErrors: Error {
    case serverVersionNotFound
    case connectionIdNotFound
    case bufferToShort
    case lengthZero
    case returningLengthZero
}