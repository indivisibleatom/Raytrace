int count = 0;

class Camera
{
  private Film m_film;
  private float m_fov;
  
  Camera( float fov, int zNear, Rect screenDim )
  {
    m_fov = fov * (PI / 180);
    m_film = new Film( screenDim );
  }
  
  public void setFov( float fov )
  {
    m_fov = fov * (PI / 180);
  }
  
  public Film getFilm()
  {
    return m_film;
  }
  
  public Point toCamera( Point screenPoint )
  {
    Point p = clonePt(screenPoint);
    Rect dimension = m_film.getDim();
    p.subtract(new Point(dimension.width()/2, dimension.height()/2, 0));
    p.toNormalizedCoordinates(dimension.width()/2, dimension.height()/2, 1);
    p.set( p.X() * tan(m_fov/2), p.Y() * tan(m_fov/2), -1 );
    return p;
  }
  
  public Ray getRay( Sample sample )
  {
    Point p = toCamera( new Point(sample.getX(), sample.getY(), 0) );
    Ray r = new Ray( c_origin, p );
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
  }

  public Rect getDim() { return m_screenDim; }
  
  public void setRadiance( Sample sample, Color col )
  {
    count++;
    //TODO msati3: Remove hardcoding of single color being equated
    m_screenColor[m_screenDim.height() - sample.getY() - 1][sample.getX()] = col;
  }
  
  public void draw()
  {
    for (int i = 0; i < m_screenDim.height(); i++)
    {
      for (int j = 0; j < m_screenDim.width(); j++)
      {  
        Color col = m_screenColor[i][j];
        if ( col != null )
        {
          color colProcessing = color( col.R(), col.G(), col.B() );
          stroke( colProcessing  );
          point( j, i );
        }
      }
    }
  }
}
