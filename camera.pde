class Camera
{
  private Film m_film;
  private float m_fov;
  private float m_focalLength;
  private float m_aperture;
  private float m_fovTan;
  
  Camera( float fov, int zNear, Rect screenDim )
  {
    m_fov = fov * (PI / 180);
    m_film = new Film( screenDim );
    m_aperture = 0;
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

  public Point getPointOnFocalPlane( Point screenPointWorld )
  {
    Vector originToScreen = new Vector( c_origin, screenPointWorld );
    float tz = -m_focalLength / originToScreen.Z();    
    Point pOnFocalPlane = new Point( c_origin, originToScreen, tz );
    return pOnFocalPlane;
  }
  
  public void toCamera( Point point )
  {
    Rect dimension = m_film.getDim();
    float[] subtractCoeffs = {dimension.width()/2, dimension.height()/2, 0};
    point.subtract(subtractCoeffs);
    point.toNormalizedCoordinates(dimension.width()/2, dimension.height()/2, 1);
    point.set( point.X() * m_fovTan, point.Y() * m_fovTan, -1 );
  }
  
  public Ray getRay( Sample sample )
  {
    Ray r;
    if ( m_aperture == 0 )
    {
      Point point = new Point(sample.getX(), sample.getY(), 0);
      toCamera( point );
      r = new Ray( c_origin, point, true );
    }
    else
    {
      Point point = new Point(sample.getX(), sample.getY(), 0);
      toCamera( point );
      Point focalPoint = getPointOnFocalPlane( point );
      r = new Ray( sampleAperture(), focalPoint, true );
    }
    return r;
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
