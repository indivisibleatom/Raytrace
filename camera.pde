class Camera
{
  private Film m_film;
  private float m_fov;
  private float m_focalLength;
  private float m_aperture;
  private float m_fovTan;
  private boolean m_shutterEnabled;

  //Increments in ray direction in camera spaer per pixel movement in file space
  private float m_xDir;
  private float m_yDir;
  private Vector m_initDirection;

  Camera( float fov, int zNear, Rect screenDim )
  {
    m_fov = fov * (PI / 180);
    m_film = new Film( screenDim );
    m_aperture = 0;
    m_shutterEnabled = false;
  }

  public void setLensParams( float aperture, float distance )
  {
    m_focalLength = distance;
    m_aperture = aperture;
  }

  public void setFov( float fov )
  {
    m_fov = fov * (PI / 180);
    m_fovTan = tan(m_fov/2);

    m_xDir = 2 * m_fovTan / m_film.getDim().width();
    m_yDir = 2 * m_fovTan / m_film.getDim().height();
    m_initDirection = new Vector( new Point(m_fovTan, m_fovTan, 0), new Point(0, 0, -1) );
  }

  public Film getFilm()
  {
    return m_film;
  }

  private Point sampleAperture()
  {
    //Rejection sampling of disk corresponding to aperture
    Point randomPoint;
    while ( true )
    {
      float randX = random(-m_aperture, m_aperture);
      float randY = random(-m_aperture, m_aperture);
      randomPoint = new Point( randX, randY, 0 );
      if ( randomPoint.squaredDistanceFrom( c_origin ) <= m_aperture * m_aperture )
      {
        break;
      }
    }
    return randomPoint;
  }

  public Point getPointOnFocalPlane( Vector rayDirection )
  {
    float tz = -m_focalLength / rayDirection.Z();    
    Point pOnFocalPlane = new Point( c_origin, rayDirection, tz );
    return pOnFocalPlane;
  }

  public Vector directionInCameraSpaceTowards( Point point )
  {
    Vector direction = new Vector(m_initDirection.X() + point.X()*m_xDir, m_initDirection.Y() + point.Y()*m_yDir, m_initDirection.Z());
    return direction;
  }

  public Ray getRayToEye( Point pointFrom )
  {
    return new Ray( pointFrom, c_origin );
  }

  public Ray getRay( Sample sample )
  {
    Ray r;
    if ( m_aperture == 0 )
    {
      Point point = new Point(sample.getX(), sample.getY(), 0);
      Vector rayDirection = directionInCameraSpaceTowards( point );
      r = new Ray( c_origin, rayDirection, true );

      Point deltaXOrig = new Point(0, 0, 0);
      Vector right = new Vector( ( 2.0 * m_fovTan / m_film.getDim().width() ), 0, 0 );
      Vector up = new Vector( 0, ( 2.0 * m_fovTan / m_film.getDim().height() ), 0 );
      float denom = 1/pow(rayDirection.dot(rayDirection), 1.5);
      Vector dDotRight = cloneVec( rayDirection ); 
      dDotRight.scale( rayDirection.dot(right) );
      Vector dDotUp = cloneVec( rayDirection ); 
      dDotUp.scale( rayDirection.dot(up) );

      Vector deltaXDir = cloneVec( right ); 
      Vector deltaYDir = cloneVec( up );
      deltaXDir.scale( rayDirection.dot(rayDirection) );
      deltaYDir.scale( rayDirection.dot(rayDirection) );
      deltaXDir.subtract( dDotRight );
      deltaYDir.subtract( dDotUp );
      deltaXDir.scale( denom );
      deltaYDir.scale( denom );

      //if ( ( sample.getY() == 300 || sample.getY() == 100 ) && sample.getX() > 290 && sample.getX() < 310 )
      //{
        Point point1 = new Point(sample.getX() + 1, sample.getY(), 0);
        Point point2 = new Point(sample.getX(), sample.getY() + 1, 0);
        Vector rayDirection1 = directionInCameraSpaceTowards( point1 ); 
        Vector rayDirection2 = directionInCameraSpaceTowards( point2 );
        Vector deltaRayDirection = cloneVec( rayDirection1 );
        
        deltaRayDirection.normalize();  
        rayDirection.normalize();
        deltaRayDirection.subtract( rayDirection );
        
        Vector deltaRayDirection1 = cloneVec( rayDirection2 );
        deltaRayDirection1.normalize();  
        deltaRayDirection1.subtract( rayDirection );
        
        /*Ray ray = new Ray( c_origin, rayDirection, true );
        Vector right1 = new Vector( (sample.getX() + 1 - m_film.getDim().width()/2) * ( 2 * m_fovTan / m_film.getDim().width() ), 0, 0 );
        Vector scaledXDirRay1 = cloneVec( rayDirection1 ); 
        scaledXDirRay1.scale( rayDirection1.dot(deltaXDir1) );
        deltaXDir1.subtract( scaledXDirRay1 );
        denom = 1/pow(rayDirection1.dot(rayDirection1), 1.5);
        deltaXDir1.scale( denom );
        float deltaX = deltaXDir1.getMagnitude();*/
        //float deltaD = deltaXDir.getMagnitude();
        //print(sample.getX() + " " + deltaRayDirection.getMagnitude() + " " + deltaD + "\n");
      //}

      r.setDifferentials( deltaXOrig, deltaXOrig, deltaRayDirection, deltaRayDirection1 );
      //r.setDifferentials( deltaXOrig, deltaXOrig, deltaXDir, deltaYDir );
      //r.debugPrintDifferentials();
    }
    else
    {
      r = null;
      Point point = new Point(sample.getX(), sample.getY(), 0);
      Vector rayDirection = directionInCameraSpaceTowards( point );
      Point focalPoint = getPointOnFocalPlane( rayDirection );
      r = new Ray( sampleAperture(), focalPoint, true );
    }
    if ( m_shutterEnabled )
    {
      r.setTime( random(0, 1) );
    }

    return r;
  }

  public void enableShutterSpeed()
  {
    m_shutterEnabled = true;
  }
}

class Film
{
  private Rect m_screenDim;
  private Color[][] m_screenColor;

  Film( Rect screenDim )
  {
    m_screenDim = screenDim;
    m_screenColor = new Color[ m_screenDim.height() ][ m_screenDim.width() ];

    for (int i = 0; i < m_screenDim.height(); i++)
    {
      for (int j = 0; j < m_screenDim.width(); j++)
      {
        m_screenColor[i][j] = new Color(0, 0, 0);
      }
    }
  }

  public Rect getDim() { 
    return m_screenDim;
  }

  public void setRadiance( Sample sample, Color col )
  {
    m_screenColor[m_screenDim.height() - sample.getPixelY() - 1][sample.getPixelX()].addUnclamped(col);
  }

  public void scaleExposure(int numSamples)
  {
    float scale = 1.0/numSamples;
    for (int i = 0; i < m_screenDim.height(); i++)
    {
      for (int j = 0; j < m_screenDim.width(); j++)
      {
        m_screenColor[i][j].scale(scale);
      }
    }
  }

  public void draw()
  {
    background (0, 0, 0);
    for (int i = 0; i < m_screenDim.height(); i++)
    {
      for (int j = 0; j < m_screenDim.width(); j++)
      {  
        Color col = m_screenColor[i][j];
        if ( col != null )
        {
          stroke( col.R(), col.G(), col.B() );
          point( j, i );
        }
      }
    }
  }
}

