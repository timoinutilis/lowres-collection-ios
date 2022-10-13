//
//  OpenGLRendererView.m
//  Pixels
//
//  Created by Timo Kloss on 14/3/16.
//  Copyright © 2016 Inutilis Software. All rights reserved.
//

#import "OpenGLRendererView.h"
#import "Renderer.h"

typedef struct {
    float Position[3];
    float TexCoord[2];
} Vertex;

const Vertex Vertices[] = {
    {{1, -1, 0}, {1, 1}},
    {{1, 1, 0}, {1, 0}},
    {{-1, 1, 0}, {0, 0}},
    {{-1, -1, 0}, {0, 1}}
};

const GLushort Indices[] = {
    0, 1, 2,
    2, 3, 0
};

@interface OpenGLRendererView()
@property (nonatomic) GLKBaseEffect *effect;
@property (nonatomic) NSMutableArray *snapshots;
@property (nonatomic) CFAbsoluteTime lastSnapshotTime;
@property (nonatomic) CIContext *ciContext;
@end

@implementation OpenGLRendererView {
    BOOL _initialized;
    GLuint _vertexBuffer;
    GLuint _indexBuffer;
    GLuint _texName;
    GLubyte *_textureData;
    int _currentSize;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    self.ciContext = [CIContext contextWithOptions:nil];
    
    // OpenGL
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    self.effect = [[GLKBaseEffect alloc] init];
}

- (void)dealloc
{
    if ([EAGLContext currentContext] == self.context)
    {
        [EAGLContext setCurrentContext:nil];
    }
    
    if (_initialized)
    {
        glDeleteBuffers(1, &_vertexBuffer);
        glDeleteBuffers(1, &_indexBuffer);
        glDeleteTextures(1, &_texName);
    }
    
    if (_textureData)
    {
        free(_textureData);
    }
}

- (void)renderTextureData
{
    if (self.renderer.displaySize != _currentSize)
    {
        if (_textureData)
        {
            free(_textureData);
        }
        _currentSize = self.renderer.displaySize;
        _textureData = (GLubyte *)calloc(_currentSize * _currentSize * 3, sizeof(GLubyte));
    }
    
    GLubyte *dataByte = _textureData;
    for (int y = 0; y < _currentSize; y++)
    {
        for (int x = 0; x < _currentSize; x++)
        {
            uint32_t color = [self.renderer screenColorAtX:x Y:y];
            *dataByte = (color >> 16) & 0xFF;
            ++dataByte;
            *dataByte = (color >> 8) & 0xFF;
            ++dataByte;
            *dataByte = (color) & 0xFF;
            ++dataByte;
        }
    }
}

- (void)drawRect:(CGRect)rect
{
    [self renderTextureData];
    
    if (!_initialized)
    {
        glGenBuffers(1, &_vertexBuffer);
        glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
        glBufferData(GL_ARRAY_BUFFER, sizeof(Vertices), Vertices, GL_STATIC_DRAW);
        
        glGenBuffers(1, &_indexBuffer);
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBuffer);
        glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(Indices), Indices, GL_STATIC_DRAW);
        
        glGenTextures(1, &_texName);
        glBindTexture(GL_TEXTURE_2D, _texName);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
        
        self.effect.texture2d0.name = _texName;
        self.effect.texture2d1.enabled = GL_FALSE;

        glClearColor(1.0, 0.0, 0.0, 1.0);
        glClear(GL_COLOR_BUFFER_BIT);
        
        glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBuffer);
        
        glEnableVertexAttribArray(GLKVertexAttribPosition);
        glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), (const GLvoid *) offsetof(Vertex, Position));
        glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
        glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(Vertex), (const GLvoid *) offsetof(Vertex, TexCoord));

        _initialized = YES;
    }
    
    [self.effect prepareToDraw];
    
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, _currentSize, _currentSize, 0, GL_RGB, GL_UNSIGNED_BYTE, _textureData);
    glDrawElements(GL_TRIANGLES, sizeof(Indices)/sizeof(Indices[0]), GL_UNSIGNED_SHORT, 0);
}

@end
