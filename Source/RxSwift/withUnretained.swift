//
//  withUnretained.swift
//  RxSwiftExt
//
//  Created by Vincent Pradeilles on 28/03/2018.
//  Copyright © 2018 RxSwiftCommunity. All rights reserved.
//

import RxSwift

private enum UnretainedError : Swift.Error {
    case objectReleased
}

extension ObservableType {
    /**
     Provides an unretained, safe to use (i.e. not implicitly unwrapped), reference to an object along with the values of the sequence
     
     - parameter obj: The object to provide an unretained reference on.
     - parameter resultSelector: A function to combine the unretained referenced on `obj` and the value of the observable sequence.
     - returns: An observable sequence that contains the result of `resultSelector` being called with an unretained reference on `obj` and the values of the original sequence.
     */
    public func withUnretained<T : AnyObject, Out>(_ obj: T, resultSelector: @escaping (T, Self.E) -> Out) -> Observable<Out> {
        return map { [weak obj] element -> Out in
            guard let obj = obj else { throw UnretainedError.objectReleased }
            
            return resultSelector(obj, element)
            }
            .catchError { error -> Observable<Out> in
                if (error as? UnretainedError) == UnretainedError.objectReleased {
                    return .empty()
                }
                return Observable.error(error)
        }
    }
    /**
     Provides an unretained, safe to use (i.e. not implicitly unwrapped), reference to an object along with the values of the sequence
     
     - parameter obj: The object to provide an unretained reference on.
     - returns: An observable sequence of tuples that contains both an unretained reference on `obj` and the values of the original sequence.
     */
    public func withUnretained<T : AnyObject>(_ obj: T) -> Observable<(T, Self.E)> {
        return withUnretained(obj, resultSelector: { obj, element in (obj, element) })
    }
}
