//
//  Shader.fsh
//  WatchKit_OpenGL
//
//  Created by ohtaisao on 2014/11/20.
//  Copyright (c) 2014年 isao. All rights reserved.
//

varying lowp vec4 colorVarying;

void main()
{
    gl_FragColor = colorVarying;
}
