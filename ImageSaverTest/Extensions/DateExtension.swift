import Foundation

extension Date {
    var day: Int {
        Calendar.current.component(.day, from: self)
    }
    
    var formattedDate: String {
        let dateFormat = "MMM d"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        
        return dateFormatter.string(from: self)
    }
}
