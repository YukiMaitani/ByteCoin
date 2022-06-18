//
//  CoinManager.swift
//  ByteCoin
//
//  Created by Angela Yu on 11/09/2019.
//  Copyright © 2019 The App Brewery. All rights reserved.
//

import Foundation

protocol CoinManagerDelegate {
    func didUpdateCoin(rateString: String, currency: String)
    func didFatalWithError(_ error: Error)
}

struct CoinManager {
    
    let baseURL = "https://rest.coinapi.io/v1/exchangerate/BTC"
    let apiKey = "3F42C5C4-4191-4E10-BE9F-CA311C23D75E"
    let currencyArray = ["AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"]
    var delegate: CoinManagerDelegate?
    
    func getCoinPrice(for currency: String) {
        let urlString = "\(baseURL)/\(currency)?apikey=\(apiKey)"
        if let url = URL(string: urlString) {
            let session = URLSession(configuration:.default)
            let task = session.dataTask(with: url) { data, response, error in
                if error != nil {
                    delegate?.didFatalWithError(error!)
                    return
                }
                
                if let data = data {
                    guard let rate = parseJOSN(data) else { return }
                    let rateString = String(format: "%.2f", rate)
                    delegate?.didUpdateCoin(rateString: rateString, currency: currency)
                }
            }
            
            task.resume()
        }
    }
    
    func parseJOSN(_ data: Data) -> Double? {
        let decoder = JSONDecoder()
        do {
            let decode = try decoder.decode(CoinData.self, from: data)
            let rate = decode.rate
            return rate
            
        } catch {
            delegate?.didFatalWithError(error)
            return nil
        }
    }

    
}
