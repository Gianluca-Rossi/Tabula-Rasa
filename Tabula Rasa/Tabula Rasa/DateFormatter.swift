//
//  DateFormatter.swift
//  Tabula Rasa
//
//  Created by Gianluca Rossi on 20/03/23.
//

import Foundation

class MyDateFormatter {
    static let sharedInstance = DateFormatter()
    private init() {
    }
}

class MyRelativeDateFormatter {
    static var sharedInstance = RelativeDateTimeFormatter()
    init() {
        MyRelativeDateFormatter.sharedInstance.dateTimeStyle = .named
        MyRelativeDateFormatter.sharedInstance.locale = Locale.current
    }
}

extension DateFormatter{
    func getDateFrom(stringDate:String,format dateFormat:String)->Date?{
        let dateFormatter = MyDateFormatter.sharedInstance
        dateFormatter.dateFormat = dateFormat
        let dateObj: Date? = dateFormatter.date(from: stringDate)
        return dateObj
    }
    
    func getStringFrom(date:Date,format dateFormat:String)->String?{
        let dateFormatter = MyDateFormatter.sharedInstance
        dateFormatter.dateFormat = dateFormat
        let dateString: String? = dateFormatter.string(from: date)
        return dateString
    }
}

func formatDate(date: String) -> String {
    let dateObj:Date? = MyDateFormatter.sharedInstance.getDateFrom(stringDate: date, format: "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'")
    let formattedDate:String? = MyDateFormatter.sharedInstance.getStringFrom(date: dateObj!, format: "EEE, dd MMM YYYY, HH:mm a")
    return formattedDate ?? ""
}
