interface Shape
{
  public Box getBoundingBox();
  public boolean intersects( Ray ray, float tMin, float tMax );
  public ShapeIntersectionInfo getIntersectionInfo( Ray ray, float tMin, float tMax );
  public float[] getTextureDifferentials( Ray r, IntersectionInfo info );
}

class Sphere implements Shape
{
  Transformation m_transformation;
  Box m_boundingBox;

  Sphere( float radius, Point center, Transformation transformation )
  {
    m_transformation = new Transformation( transformation );
    m_transformation.translate( new Vector( c_origin, center ) );
    m_transformation.scale( radius );

    m_boundingBox = new Box( new Point(-1, -1, -1), new Point(1, 1, 1), m_transformation );
    m_boundingBox = m_boundingBox.getBoundingBox();
  }

  private boolean intersectsCanonical( Ray ray, float tMin, float tMax )
  {
    Vector OA = new Vector( c_origin, ray.getOrigin() );    
    float scale = 1/ray.getDirection().getMagnitude();
    Vector dirNorm = cloneVec( ray.getDirection() );
    dirNorm.normalize();

    float b = 2*OA.dot(dirNorm);
    float a = 1;
    float c = OA.getMagnitudeSquare() - 1;
    float delta = b*b - 4*a*c;
    if ( delta < 0 )
      return false;

    float sqrtDelta = sqrt( delta );
    float root1 = (-b + sqrtDelta) / 2;
    float root2 = (-b - sqrtDelta) / 2;
    if (root1 < c_epsilon && root2 < c_epsilon)
    {
      return false;
    }

    float minT;
    if ( root1 > c_epsilon && ( root1 < root2 || root2 < 0 ) )
    {
      minT = root1;
    }
    else
    {
      minT = root2;
    }

    float minTScaled = minT * scale;
    if ( minT < 0 || minTScaled < tMin || minTScaled > tMax )
    {
      return false;
    }
    return true;
  }

  private ShapeIntersectionInfo intersectionInfoCanonical( Ray ray, float tMin, float tMax )
  {
    Vector OA = new Vector( c_origin, ray.getOrigin() );
    float scale = 1/ray.getDirection().getMagnitude();
    Vector dirNorm = cloneVec( ray.getDirection() );
    dirNorm.normalize();

    float b = 2*OA.dot(dirNorm);
    float a = 1;
    float c = OA.getMagnitudeSquare() - 1;
    float delta = b*b - 4*a*c;
    if ( delta < 0 )
    {
      return null;
    }
    else
    {
      float sqrtDelta = sqrt( delta );
      float root1 = (-b + sqrtDelta) / 2;
      float root2 = (-b - sqrtDelta) / 2;
      if (root1 < c_epsilon && root2 < c_epsilon)
      {
        return null;
      }

      float minT;
      if ( root1 > 0 && ( root1 < root2 || root2 < 0 ) )
      {
        minT = root1;
      }
      else
      {
        minT = root2;
      }

      float minTScaled = minT * scale;
      if ( minT < 0 || minTScaled < tMin || minTScaled > tMax )
      {
        return null;
      }

      Point intersectionPointLocal = new Point( ray, minTScaled );
      Vector normalLocal = new Vector( c_origin, intersectionPointLocal );

      //Now go to world space
      Point intersectionPoint = m_transformation.localToWorld( intersectionPointLocal );
      Vector normal = m_transformation.localToWorldNormal( normalLocal );
      return new ShapeIntersectionInfo( intersectionPoint, normal, null, minTScaled, false ); //texture mapping of sphere not supported right now
    }
  }

  public Box getBoundingBox()
  {
    return m_boundingBox;
  }

  public boolean intersects( Ray ray, float tMin, float tMax )
  {
    Ray rayLocal = m_transformation.worldToLocalUnnormalized( ray );
    return intersectsCanonical( rayLocal, tMin, tMax );
  }
  
  public float[] getTextureDifferentials( Ray r, IntersectionInfo info )
  {
    return null;
  }

  public ShapeIntersectionInfo getIntersectionInfo( Ray ray, float tMin, float tMax )
  {
    Ray rayLocal = m_transformation.worldToLocalUnnormalized( ray );
    return intersectionInfoCanonical( rayLocal, tMin, tMax );
  }
}

class NonCanonSphere implements Shape
{
  Box m_boundingBox;
  Point m_center;
  float m_radius2;

  NonCanonSphere( float radius, Point center )
  {
    m_radius2 = radius * radius;
    m_center = center;
  
    print("Creating non-canon sphere " + radius + " ");
    center.debugPrint();
    m_boundingBox = new Box( new Point(m_center.X() - radius, m_center.Y() - radius, m_center.Z() - radius), new Point(m_center.X() + radius, m_center.Y() + radius, m_center.Z() + radius), null );
  }

  public boolean intersects( Ray ray, float tMin, float tMax )
  {
    Vector OA = new Vector( m_center, ray.getOrigin() );

    float b = 2*OA.dot(ray.getDirection());
    float a = 1;
    float c = OA.getMagnitudeSquare() - m_radius2;
    float delta = b*b - 4*a*c;
    if ( delta < 0 )
    {
      return false;
    }

    float sqrtDelta = sqrt( delta );
    float root1 = (-b + sqrtDelta) / 2;
    float root2 = (-b - sqrtDelta) / 2;
    if (root1 < c_epsilon && root2 < c_epsilon)
    {
      return false;
    }

    float minT;
    if ( root1 > c_epsilon && ( root1 < root2 || root2 < 0 ) )
    {
      minT = root1;
    }
    else
    {
      minT = root2;
    }

    if ( minT < 0 || minT < tMin || minT > tMax )
    {
      return false;
    }
    return true;
  }
  
  private Point getTextureCoords( Point onSphere )
  {
    Vector intersectToOrigin = new Vector( onSphere, m_center );
    intersectToOrigin.normalize();
      
    float u = 0.5 + atan2(intersectToOrigin.Y(), intersectToOrigin.X())/(2*PI);
    float v = 0.5 - asin(intersectToOrigin.Z())/PI;
    return new Point(u,v,0);
  }
  
  public ShapeIntersectionInfo getIntersectionInfo( Ray ray, float tMin, float tMax )
  {
    Vector OA = new Vector( m_center, ray.getOrigin() );

    float b = 2*OA.dot(ray.getDirection());
    float a = 1;
    float c = OA.getMagnitudeSquare() - m_radius2;
    float delta = b*b - 4*a*c;
    if ( delta < 0 )
    {
      return null;
    }
    else
    {
      float sqrtDelta = sqrt( delta );
      float root1 = (-b + sqrtDelta) / 2;
      float root2 = (-b - sqrtDelta) / 2;
      if (root1 < c_epsilon && root2 < c_epsilon)
      {
        return null;
      }

      float minT;
      if ( root1 > 0 && ( root1 < root2 || root2 < 0 ) )
      {
        minT = root1;
      }
      else
      {
        minT = root2;
      }

      if ( minT < 0 || minT < tMin || minT > tMax )
      {
        return null;
      }

      Point intersectionPoint = new Point( ray, minT );
      Vector normal = new Vector( m_center, intersectionPoint );
      normal.normalize();

      Point uv = getTextureCoords( intersectionPoint );
      
      return new ShapeIntersectionInfo( intersectionPoint, normal, uv, minT, false ); //Texture mapping of non canon sphere not supported right now
    }
  }
  
  public float[] getTextureDifferentials( Ray ray, IntersectionInfo info )
  {
    Point intersectionPoint = info.point();
    Point uv = info.textureCoord();
    float[] retVal = new float[2]; 
    uv.setZ(0);

    Point shiftedX = clonePt( intersectionPoint );
    Point shiftedY = clonePt( intersectionPoint );
    Point deltaX = ray.getDeltaX();
    Point deltaY = ray.getDeltaY();
    float delta = 0.1;
    shiftedX.set( shiftedX.X() + delta * deltaX.X(), shiftedX.Y() + delta * deltaX.Y(), shiftedX.Z() + delta * deltaX.Z() );
    Point uvDeltaX = getTextureCoords( shiftedX );
    shiftedY.set( shiftedY.X() + delta * deltaY.X(), shiftedY.Y() + delta * deltaY.Y(), shiftedY.Z() + delta * deltaY.Z() );
    Point uvDeltaY = getTextureCoords( shiftedY );

    Vector v1 = new Vector( uv, uvDeltaX );
    v1.scale(1.0/delta);
    Vector v2 = new Vector( uv, uvDeltaY );
    v2.scale(1.0/delta);

    float m1 = v1.getMagnitude();
    m1 = abs(m1);
    if  ( m1 > 1 ) m1 = 2 - m1;
    float m2 = v2.getMagnitude();
    m2 = abs(m2);
    if  ( m2 > 1 ) m2 = 2 - m2;
    retVal[0] = m1; retVal[1] = m2;
    return retVal;
  }

  public Box getBoundingBox()
  {
    return m_boundingBox;
  }
}

class MovingSphere implements Shape
{
  Box m_boundingBox;
  Point m_center1;
  Point m_center2;
  Vector m_totalMotion;
  float m_radius2;

  MovingSphere( float radius, Point center1, Point center2 )
  {
    m_radius2 = radius * radius;
    m_center1 = center1;
    m_center2 = center2;
    m_totalMotion = new Vector( m_center1, m_center2 );
    
    //TODO msati3: Handle reverse order of specification of centers.
    m_boundingBox = new Box( new Point(m_center1.X() - radius, m_center1.Y() - radius, m_center1.Z() - radius), new Point(m_center2.X() + radius, m_center2.Y() + radius, m_center2.Z() + radius), null );
  }

  public boolean intersects( Ray ray, float tMin, float tMax )
  {
    Point centerCurrent = new Point( m_center1, m_totalMotion, ray.getTime() );
    Vector OA = new Vector( centerCurrent, ray.getOrigin() );   

    float b = 2*OA.dot(ray.getDirection());
    float a = 1;
    float c = OA.getMagnitudeSquare() - m_radius2;
    float delta = b*b - 4*a*c;
    if ( delta < 0 )
    {
      return false;
    }

    float sqrtDelta = sqrt( delta );
    float root1 = (-b + sqrtDelta) / 2;
    float root2 = (-b - sqrtDelta) / 2;
    if (root1 < c_epsilon && root2 < c_epsilon)
    {
      return false;
    }

    float minT;
    if ( root1 > c_epsilon && ( root1 < root2 || root2 < 0 ) )
    {
      minT = root1;
    }
    else
    {
      minT = root2;
    }

    if ( minT < 0 || minT < tMin || minT > tMax )
    {
      return false;
    }
    return true;
  }

  public ShapeIntersectionInfo getIntersectionInfo( Ray ray, float tMin, float tMax )
  {
    Point centerCurrent = new Point( m_center1, m_totalMotion, ray.getTime() );
    Vector OA = new Vector( centerCurrent, ray.getOrigin() );   

    float b = 2*OA.dot(ray.getDirection());
    float a = 1;
    float c = OA.getMagnitudeSquare() - m_radius2;
    float delta = b*b - 4*a*c;
    if ( delta < 0 )
    {
      return null;
    }
    else
    {
      float sqrtDelta = sqrt( delta );
      float root1 = (-b + sqrtDelta) / 2;
      float root2 = (-b - sqrtDelta) / 2;
      if (root1 < c_epsilon && root2 < c_epsilon)
      {
        return null;
      }

      float minT;
      if ( root1 > 0 && ( root1 < root2 || root2 < 0 ) )
      {
        minT = root1;
      }
      else
      {
        minT = root2;
      }

      if ( minT < 0 || minT < tMin || minT > tMax )
      {
        return null;
      }

      Point intersectionPoint = new Point( ray, minT );
      Vector normal = new Vector( centerCurrent, intersectionPoint );
      normal.normalize();

      return new ShapeIntersectionInfo( intersectionPoint, normal, null, minT, false ); //Texture mapping of moving sphere not supported right now
    }
  }

  public float[] getTextureDifferentials( Ray r, IntersectionInfo info )
  {
    return null;
  }

  public Box getBoundingBox()
  {
    return m_boundingBox;
  }
}

class Triangle implements Shape
{
  Transformation m_transformation;
  Point[] m_vertices;
  Point[] m_textureCoords;
  Vector m_normal;
  Vector m_e1;
  Vector m_e2;
  Box m_boundingBox;

  Triangle( Point p1, Point p2, Point p3, Point texCoords1, Point texCoords2, Point texCoords3, Transformation transformation )
  {
    m_vertices = new Point[3];
    m_transformation = new Transformation( transformation );
    m_vertices[0] = m_transformation.localToWorld( p1 );
    m_vertices[1] = m_transformation.localToWorld( p2 );
    m_vertices[2] = m_transformation.localToWorld( p3 );

    m_textureCoords = null;
    if ( texCoords1 != null )
    {
      m_textureCoords = new Point[3];
      m_textureCoords[0] = texCoords1;
      m_textureCoords[1] = texCoords2;
      m_textureCoords[2] = texCoords3;
    }

    m_e1 = new Vector( m_vertices[0], m_vertices[1] );
    m_e2 = new Vector( m_vertices[0], m_vertices[2] );

    m_normal = m_e1.cross( m_e2 );
    m_normal.normalize();

    m_boundingBox = new Box( m_vertices ).getBoundingBox();
  }

  public Box getBoundingBox()
  {
    return m_boundingBox;
  }
  
  private float[] getTextureCoordScaled( float u, float v )
  {
    float[] textureCoordinates = new float[3];  
    
    textureCoordinates[0] = (1-u-v)*m_textureCoords[0].X() + u*m_textureCoords[1].X() + v*m_textureCoords[2].X();
    textureCoordinates[1] = (1-u-v)*m_textureCoords[0].Y() + u*m_textureCoords[1].Y() + v*m_textureCoords[2].Y();
    textureCoordinates[2] = 0;
    
    return textureCoordinates;
  }
 
  //Optimized ray triangle intersection
  private float intersectInternal( Ray ray, float tMin, float tMax, Point textureCoord )
  {
    Vector p = ray.getDirection().cross( m_e2 );
    Vector tVec, q;
    float det = m_e1.dot( p );
    float u, v, t;
    if ( det > c_epsilon )
    {
      tVec = new Vector( m_vertices[0], ray.getOrigin() );
      u = tVec.dot(p);
      if ( u < 0.0 || u > det )
        return 0;

      q = tVec.cross( m_e1 );
      v = ray.getDirection().dot( q );
      if ( v < 0.0 || v + u > det )
        return 0;
    }
    else if ( det < -c_epsilon )
    {
      tVec = new Vector( m_vertices[0], ray.getOrigin() );
      u = tVec.dot(p);
      if ( u > 0.0 || u < det )
        return 0;

      q = tVec.cross( m_e1 );
      v = ray.getDirection().dot( q );
      if ( v > 0.0 || v + u < det )
        return 0;
    }
    else
    {
      return 0;
    }
    float tIntersection = m_e2.dot( q ) / det;
    if ( tIntersection < c_epsilon || tIntersection < tMin || tIntersection > tMax )
    {
      return 0;
    }
    if ( textureCoord != null )
    {
      u /= det;
      v /= det;
      float textureCoords[] = getTextureCoordScaled( u, v );
      textureCoord.set( textureCoords[0], textureCoords[1], textureCoords[2] );
    }
    return tIntersection;
  }
  
  public float[] getTextureDifferentials( Ray ray, IntersectionInfo info )
  {
    Point uv = info.textureCoord();
    uv.setZ(0);
    float[] retVal = new float[2];
    Vector deltaX = new Vector( new Point(0,0,0), ray.getDeltaX() );
    Vector deltaY = new Vector( new Point(0,0,0), ray.getDeltaY() );
    
    /*Vector La = new Vector( m_vertices[1], m_vertices[2] );
    Vector P = new Vector( new Point(0,0,0), m_vertices[0] );
    float dot = P.dot(La);
    La.scale( 1/dot );
    
    Vector Lb = new Vector( m_vertices[2], m_vertices[0] );
    P = new Vector( new Point(0,0,0), m_vertices[1] );
    dot = P.dot(Lb);
    Lb.scale( 1/dot );
    
    Vector Lc = new Vector( m_vertices[0], m_vertices[1] );
    P = new Vector( new Point(0,0,0), m_vertices[2] );
    dot = P.dot(Lc);
    Lc.scale( 1/dot );
    
    Point DtDx = new Point( La.dot(deltaX), Lb.dot(deltaX), Lc.dot(deltaX), m_textureCoords[0], m_textureCoords[1], m_textureCoords[2] );
    Point DtDy = new Point( La.dot(deltaY), Lb.dot(deltaY), Lc.dot(deltaY), m_textureCoords[0], m_textureCoords[1], m_textureCoords[2] );*/
    
    Vector e1 = new Vector( m_textureCoords[0], m_textureCoords[1] );
    Vector e2 = new Vector( m_textureCoords[0], m_textureCoords[2] );
    
    Point DtDx = new Point( deltaX.dot( e1 ), deltaX.dot( e2 ), 0 );
    Point DtDy = new Point( deltaY.dot( e1 ), deltaY.dot( e2 ), 0 );
    
    float m1 = DtDx.getMagnitude();
    m1 = abs(m1);
    if  ( m1 > 1 ) m1 = m1 - 1;
    float m2 = DtDy.getMagnitude();
    m2 = abs(m2);
    if  ( m2 > 1 ) m2 = m2 - 1;

    retVal[0] = m1;
    retVal[1] = m2;
    return retVal;
  }

  public boolean intersects( Ray ray, float tMin, float tMax )
  {
    Point textureCoord = null;
    return ( intersectInternal( ray, tMin, tMax, textureCoord ) != 0 );
  }


  public ShapeIntersectionInfo getIntersectionInfo( Ray ray, float tMin, float tMax )
  {
    Point textureCoord = null;
    if (m_textureCoords != null)
    {
      textureCoord = new Point(0,0,0);
    }
    float t = intersectInternal( ray, tMin, tMax, textureCoord );
    if ( t != 0 )
    {
      Point inPlane = new Point( ray, t );
      return new ShapeIntersectionInfo( inPlane, m_normal, textureCoord, t, true );
    }
    return null;
  }
}

