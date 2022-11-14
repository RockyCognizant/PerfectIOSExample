//
//  PerfectIOSExampleTests.swift
//  PerfectIOSExampleTests
//
//  Created by Xiaoquan Wei on 11/14/22.
//

import PerfectHTTP
import PerfectHTTPServer

import XCTest
@testable import PerfectIOSExample

final class PerfectIOSExampleTests: XCTestCase {

    var httpServer: HTTPServer.LaunchContext?
    let greetings = "Hello, world!"
    let port = 8181
    let host = "localhost"
    func handler(request: HTTPRequest, response: HTTPResponse) {
        response.setHeader(.contentType, value: "text/plain")
        response.appendBody(string: greetings)
        response.completed()
    }

    override func setUpWithError() throws {
        var routes = Routes()
        routes.add(method: .get, uri: "/", handler: handler)
        httpServer = try HTTPServer.launch(wait: false, name: host, port: port, routes: routes)
    }

    override func tearDownWithError() throws {
        httpServer?.terminate()
    }

    func testExample() throws {
        guard let url = URL(string: "http://\(host):\(port)") else {
            XCTFail("invalid url")
            return
        }
        let exp = expectation(description: greetings)
        URLSession.shared.dataTask(with: URLRequest(url: url)) { data, _, error in
            XCTAssertNil(error)
            guard let data = data,
                  let text = String(data: data, encoding: .utf8) else {
                XCTFail("invalid response body")
                return
            }
            XCTAssertEqual(text, "Hello, world!")
            exp.fulfill()
        }.resume()
        wait(for: [exp], timeout: 10)
    }
}
