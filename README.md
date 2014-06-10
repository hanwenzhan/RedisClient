# RedisClient

This project aims to implement the redis [RESP](http://redis.io/topics/protocol) protocol in [Swift](https://developer.apple.com/swift/).
It runs on OS X 10.10 Yosemite. The RedisClient.swift should be usable under iOS 8 as well.

## Goals
This is the first time I write in Swift and a learning effort. The product might be buggy, unusable, slow and insecure.
If you want a redis client for production use you are better of writing your own Objective-C wrapper for [hiredis](https://github.com/redis/hiredis).

Things I want to experiment with in this project:
* structuring a Swift project, using protocols and extensions
* error handling
* interacting with existing C and Objective C APIs
* a little bit Mac OS X UI

## License
The MIT License (MIT)

Copyright (c) 2014 Christian Lobach

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
