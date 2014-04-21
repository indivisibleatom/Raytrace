class Camera
{
  private Film m_film;
  private float m_fov;
  private float m_focalLength;
  private float m_aperture;
  private float m_fovTan;
  private boolean m_shutterEnabled;
  private Point m_position; 

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
    m_position = new Point(0,0,0);
  }
  
  public void moveForward()
  {
    m_position.setZ( m_position.Z() - 1.0 );
    g_scene.reRender();
  }
  
  public void moveBackward()
  {
    m_position.setZ( m_position.Z() + 1.0 );
    g_scene.reRender();
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
    Point pOnFocalPlane = new Point( m_position, rayDirection, tz );
    return pOnFocalPlane;
  }

  public Vector directionInCameraSpaceTowards( Point point )
  {
    Vector direction = new Vector(m_initDirection.X() + point.X()*m_xDir, m_initDirection.Y() + point.Y()*m_yDir, m_initDirection.Z());
    return direction;
  }

  public Ray getRayToEye( Point pointFrom )
  {
    return new Ray( pointFrom, m_position );
  }

  public Ray getRay( Sample sample )
  {
    Ray r;
    if ( m_aperture == 0 )
    {
      Point point = new Point(sample.getX(), m_film.getDim().height() - sample.getY() - 1, 0);
      Vector rayDirection = directionInCameraSpaceTowards( point );

      Point deltaXOrig = new Point(0, 0, 0);
      Vector right = new Vector( ( 2.0 * m_fovTan / m_film.getDim().width() ), 0, 0 );
      Vector up = new Vector( 0, -( 2.0 * m_fovTan / m_film.getDim().height() ), 0 );
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
      
      r = new Ray( m_position, rayDirection, true );
      r.setDifferentials( deltaXOrig, deltaXOrig, deltaXDir, deltaYDir );
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
  private DepthMap m_depthMap;
  PImage m_backingImage;

  Film( Rect screenDim )
  {
    m_screenDim = screenDim;
    m_screenColor = new Color[ m_screenDim.height() ][ m_screenDim.width() ];
    m_depthMap = new DepthMap( screenDim );
    m_backingImage = new PImage( m_screenDim.width(), m_screenDim.height() );
  }
  
  public void clear()
  {
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
    m_screenColor[sample.getPixelY()][sample.getPixelX()].addUnclamped(col);
  }

  public void setDepthValue( Sample sample, float value )
  {
    m_depthMap.setValue( sample.getPixelY(), sample.getPixelX(), value );
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
  
  public void modulateColor( int row, int column, float value )
  {
    m_screenColor[row][column].scale( value );
  }

  public void draw()
  {
    background (0, 0, 0);
    print("Here\n");
    m_depthMap.postProcess(this);
    for (int i = 0; i < m_screenDim.height(); i++)
    {
      for (int j = 0; j < m_screenDim.width(); j++)
      {  
        Color col = m_screenColor[i][j];
        if ( col != null )
        {
          m_backingImage.set( j, i, col.getIntColor() );
        }
      }
    }
    image(m_backingImage, 0, 0);
  }
}

