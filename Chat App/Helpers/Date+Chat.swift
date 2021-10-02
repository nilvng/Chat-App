//
//  Date+Chat.swift
//  Chat App
//
//  Created by Nil Nguyen on 9/30/21.
//

import Foundation

extension Date {
    static func - (recent: Date, previous: Date) -> (month: Int?, year: Int?){
        //from.timeIntervalSince(to)
        let month = Calendar.current.dateComponents([.month], from: previous, to: recent).month
        let year = Calendar.current.dateComponents([.year], from: previous, to: recent).year
        return (month, year)
    }
}

extension String {

    func toDate(withFormat format: String = "yyyy-MM-dd HH:mm:ss ")-> Date?{

        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: "Asia/Bankok")
        dateFormatter.locale = Locale(identifier: "vi_VN")
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.dateFormat = format
        let date = dateFormatter.date(from: self)

        return date

    }
}
