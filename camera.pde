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
  
  public Ray getRay( Sample sample )
  {
    Ray r;
    if ( m_aperture == 0 )
    {
      Point point = new Point(sample.getX(), sample.getY(), 0);
      Vector rayDirection = directionInCameraSpaceTowards( point );
      r = new Ray( c_origin, rayDirection, true );
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
        m_screenColor[i][j] = new Color(0,0,0);  
      }
    }
  }

  public Rect getDim() { return m_screenDim; }
  
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
