class ImageTexture 
{ 
  PImage image;
  PImage[] image_pyramid;
  PImage[][] ripMaps;
  int levels;  // number of pyramid levels
  
  ImageTexture (String filename) 
  {
    int i;
    
    image = loadImage (filename);  // read in a texture
    
    // create the image pyramid

    // determine how many pyramid levels we will need
    int min = min (image.width, image.height);
    levels = 1;
    while (min > 1) {
      min /= 2;
      levels++;
    }
    
    println ("w h: " + image.width + " " + image.height + " levels = " + levels);
    
    // allocate space for all pyramid levels
    image_pyramid = new PImage[levels];
    ripMaps = new PImage[levels][];
    for (i = 0; i < levels; i++)
    {
      ripMaps[i] = new PImage[levels];
    }
    
    // create the base of the pyramid (the highest resolution image)
    int w = image.width;
    int h = image.height;
    image_pyramid[0] = new PImage (w, h, RGB);
    image_pyramid[0].copy (image, 0, 0, w, h, 0, 0, w, h);
    
    // create all the other levels of the pyramid
    for (i = 1; i < levels; i++) {
      image_pyramid[i] = new PImage (w, h, RGB);
      image_pyramid[i].copy (image_pyramid[i-1], 0, 0, w, h, 0, 0, w, h);
      image_pyramid[i].resize (w/2, h/2);
      image_pyramid[i].save("C:/Users/Mukul/Desktop/ray_tracer/temp/MipMap"+i);
      w /= 2;
      h /= 2;
    }
    
    // create the rip-maps
    w = image.width;
    h = image.height; 

    ripMaps[0][0] = new PImage(w,h,RGB);
    ripMaps[0][0].copy (image, 0, 0, w, h, 0, 0, w, h);
    ripMaps[0][0].save("C:/Users/Mukul/Desktop/ray_tracer/temp/RipMap"+0+0);
    for (i = 0; i < levels; i++) 
    {
      w = image.width;
      if ( i != 0 )
      {
        ripMaps[i][0] = new PImage(w,h,RGB);
        ripMaps[i][0].copy (ripMaps[i-1][0], 0, 0, w, h, 0, 0, w, h);
        ripMaps[i][0].resize(w, h/2);
        ripMaps[i][0].save("C:/Users/Mukul/Desktop/ray_tracer/temp/RipMap"+i+0);
        if ( i > 1 )
        {
          h /= 2;
        }
      }
      for (int j = 1; j < levels; j++)
      {
        ripMaps[i][j] = new PImage (w, h, RGB);
        ripMaps[i][j].copy (ripMaps[i][j-1], 0, 0, w, h, 0, 0, w, h);
        ripMaps[i][j].resize (w/2, h);
        ripMaps[i][j].save("C:/Users/Mukul/Desktop/ray_tracer/temp/RipMap"+i+j);
        w /= 2;
      }
    }
  }
  
  // return nearest neighbor color (which will alias)
  PVector get_color (int i, int j, int level) 
  {
    color c = image_pyramid[level].get(i,j);
    PVector col = new PVector (red(c), green(c), blue(c));
    return (col);
  }

  // return nearest neighbor color (which will alias)
  PVector get_color (int i, int j, int levelX, int levelY) 
  {
    color c = ripMaps[levelY][levelX].get(i,j);
    PVector col = new PVector (red(c), green(c), blue(c));
    return (col);
  }
  
  PVector color_valueAniso (PVector uv, PVector xy) 
  { 
    int i,j;
    int ii,jj;
    float ufloat,vfloat;
    float s,t;
    PVector c00,c10,c01,c11;
    PVector c0,c1,ca,cb,c;
    
    float u = uv.x;
    float v = uv.y;
    float uv_widthX = xy.x;
    float uv_heightY = xy.y;
    
    // calculate the mipmap level to use, based on
    // the width of the pixel's footprint
    
    if (uv_widthX < 1e-8) uv_widthX = 1e-8;
    if (uv_heightY < 1e-8) uv_heightY = 1e-8;
    float levX = levels - 1 + log (uv_widthX) / log (2.0);
    float levY = levels - 1 + log (uv_heightY) / log (2.0);
   
    if (levX < 0) levX = 0;
    if (levY < 0) levY = 0;
    if (levX >= levels-1) levX = levels - 1.01;
    if (levY >= levels-1) levY = levels - 1.01;
    
    int levelX = int (levX);
    int levelY = int (levY);
    //print(levelX + " " + levelY + "    ");

    float level_fractX = levX - levelX;
    float level_fractY = levY - levelY;
    float level_fract = sqrt( level_fractX*level_fractX + level_fractY*level_fractY );
    
    // clamp the texture coordinates
    if (u < 0) u = 0;
    if (u > 1) u = 1;
    if (v < 0) v = 0;
    if (v > 1) v = 1;
    
    // determine fractional position between texels
    ufloat = u * ripMaps[levelY][levelX].width;
    vfloat = (1 - v) * ripMaps[levelY][levelX].height;
    i = (int) (ufloat);
    j = (int) (vfloat);
    s = ufloat - i;
    t = vfloat - j;
    ii = i+1;
    jj = j+1;
    if (ii >= ripMaps[levelY][levelX].width) ii = ripMaps[levelY][levelX].width-1;
    if (jj >= ripMaps[levelY][levelX].height) jj = ripMaps[levelY][levelX].height-1;
    
    // perform bilinear interpolation between the four nearest samples
    c00 = get_color (i,j,levelX,levelY);
    c10 = get_color (ii,j,levelX,levelY);
    c01 = get_color (i,jj,levelX,levelY);
    c11 = get_color (ii,jj,levelX,levelY);
    
    c0 = PVector.lerp (c00, c10, s);
    c1 = PVector.lerp (c01, c11, s);
    ca = PVector.lerp (c0, c1, t);
    
    // move up to next level
    levelX++;
    levelY++;
    
    // determine fractional position between texels
    ufloat = u * ripMaps[levelY][levelX].width;
    vfloat = (1 - v) * ripMaps[levelY][levelX].height;
    i = (int) (ufloat);
    j = (int) (vfloat);
    s = ufloat - i;
    t = vfloat - j;
    ii = i+1;
    jj = j+1;
    if (ii >= ripMaps[levelY][levelX].width) ii = ripMaps[levelY][levelX].width-1;
    if (jj >= ripMaps[levelY][levelX].height) jj = ripMaps[levelY][levelX].height-1;
    
    // perform bilinear interpolation between the four nearest samples
    c00 = get_color (i,j,levelX, levelY);
    c10 = get_color (ii,j,levelX, levelY);
    c01 = get_color (i,jj,levelX, levelY);
    c11 = get_color (ii,jj,levelX, levelY);
    
    c0 = PVector.lerp (c00, c10, s);
    c1 = PVector.lerp (c01, c11, s);
    cb = PVector.lerp (c0, c1, t);
    
    // blend between levels
    c = PVector.lerp (ca, cb, level_fract);
    
    return (c);
  }
  
  // Return the color from a mipmap, based on texture coordinates and filter width.
  // The filter width is a distance in texture space.
  //
  // uvw: contains (u,v) texture coordinate in the x and y fields, and filter width in the z field 
  PVector color_value (PVector uvw) 
  { 
    int i,j;
    int ii,jj;
    float ufloat,vfloat;
    float s,t;
    PVector c00,c10,c01,c11;
    PVector c0,c1,ca,cb,c;
    
    float u = uvw.x;
    float v = uvw.y;
    float uv_width = uvw.z;
    
    // calculate the mipmap level to use, based on
    // the width of the pixel's footprint
    
    if (uv_width < 1e-8) uv_width = 1e-8;
    float lev = levels - 1 + log (uv_width) / log (2.0);
    if (lev < 0) lev = 0;
    if (lev >= levels-1) lev = levels - 1.01;
    
    int level = int (lev);
    float level_fract = lev - level;
    
    // clamp the texture coordinates
    if (u < 0) u = 0;
    if (u > 1) u = 1;
    if (v < 0) v = 0;
    if (v > 1) v = 1;
    
    // determine fractional position between texels
    ufloat = u * image_pyramid[level].width;
    vfloat = (1 - v) * image_pyramid[level].height;
    i = (int) (ufloat);
    j = (int) (vfloat);
    s = ufloat - i;
    t = vfloat - j;
    ii = i+1;
    jj = j+1;
    if (ii >= image_pyramid[level].width) ii = image_pyramid[level].width-1;
    if (jj >= image_pyramid[level].height) jj = image_pyramid[level].height-1;
    
    // perform bilinear interpolation between the four nearest samples
    c00 = get_color (i,j,level);
    c10 = get_color (ii,j,level);
    c01 = get_color (i,jj,level);
    c11 = get_color (ii,jj,level);
    
    c0 = PVector.lerp (c00, c10, s);
    c1 = PVector.lerp (c01, c11, s);
    ca = PVector.lerp (c0, c1, t);
    
    // move up to next level
    level++;
    
    // determine fractional position between texels
    ufloat = u * image_pyramid[level].width;
    vfloat = (1 - v) * image_pyramid[level].height;
    i = (int) (ufloat);
    j = (int) (vfloat);
    s = ufloat - i;
    t = vfloat - j;
    ii = i+1;
    jj = j+1;
    if (ii >= image_pyramid[level].width) ii = image_pyramid[level].width-1;
    if (jj >= image_pyramid[level].height) jj = image_pyramid[level].height-1;
    
    // perform bilinear interpolation between the four nearest samples
    c00 = get_color (i,j,level);
    c10 = get_color (ii,j,level);
    c01 = get_color (i,jj,level);
    c11 = get_color (ii,jj,level);
    
    c0 = PVector.lerp (c00, c10, s);
    c1 = PVector.lerp (c01, c11, s);
    cb = PVector.lerp (c0, c1, t);
    
    // blend between levels
    c = PVector.lerp (ca, cb, level_fract);
    
    return (c);
  }
}
