//
//  Example
//  man
//
//  Created by man on 11/11/2018.
//  Copyright © 2018 man. All rights reserved.
//

import Foundation

struct NetworkDetailModel {
    var title: String?
    var content: String?
    var image: UIImage?
    var blankContent: String?
    var isLast: Bool = false
    var requestSerializer: RequestSerializer = RequestSerializer.JSON//默认JSON格式
    var requestHeaderFields: [String: Any]?
    var responseHeaderFields: [String: Any]?
    
    init(title: String? = nil, content: String? = "", _ image: UIImage? = nil) {
        self.title = title
        self.content = content
        self.image = image
    }
}
