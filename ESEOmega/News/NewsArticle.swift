//
//  NewsArticle.swift
//  ESEOmega
//
//  Created by Tomn on 08/09/2017.
//  Copyright © 2017 Thomas Naudet

//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.

//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.

//  You should have received a copy of the GNU General Public License
//  along with this program. If not, see http://www.gnu.org/licenses/
//

import Foundation

/// Describes a news article and its attributes
struct NewsArticle: Codable, Equatable {
    
    /// Unique identifier for the article
    let ID: Int
    
    /// Title of the news article
    let title: String
    
    /// Short text describing the content,
    /// usually the first words
    let preview: String
    
    /// HTML content of the article
    let content: String
    
    /// Date when the article was written/published
    let date: Date
    
    /// Club attribution (ID)
    let club: String
    
    /// Club attribution (name)
    let clubName: String
    
    /// User attribution
    let creator: String
    
    /// We'll only display this article if true
    let displayInApps: Bool
    
    /// Illustration, club image… associated with the article
    let img: String?
    
    /// Link to article on BDE website.
    /// Consider using `getURL()` instead.
    let url: String?
    
    
    // If the BDE has no website link, let's make one
    func getURL() -> URL? {
        
        if url == nil {
            return URL(string: "https://bdeeseo.fr/news/\(ID)")
        }
        return URL(string: url!)
    }
    
    static let dateFormat = "yyyy-MM-dd HH:mm:ss"
    
    static func == (left: NewsArticle, right: NewsArticle) -> Bool {
        return left.ID == right.ID
    }
    
}


/// Describes a News JSON response from API
struct NewsResult: APIResult, Decodable {
    
    let success: Bool
    
    let page: Int
    
    let news: [NewsArticle]
    
}
