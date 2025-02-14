// MIT No Attribution
// 
// Copyright 2025 KIVoP
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy of this
// software and associated documentation files (the Software), to deal in the Software
// without restriction, including without limitation the rights to use, copy, modify,
// merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
// INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
// PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
// OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
// SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

import Fluent
import Foundation

public final class PosterPositionResponsibilities: Model, @unchecked Sendable {
    public static let schema = "poster_position_responsibilities"
    
    @ID(key: .id)
    public var id: UUID?

    @Parent(key:"user_id")
    public var user: User

    @Parent(key:"poster_position_id")
    public var poster_position: PosterPosition
    
    public init() { }

    public init(id: UUID? = nil, userID:UUID,posterPositionID:UUID ) {
        self.id = id
        self.$user.id = userID
        self.$poster_position.id = posterPositionID
    }
    
}


    
