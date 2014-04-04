class Material
{
  private Color m_ambient;
  private Color m_diffuse;
  private Color m_specular;
  private float m_power;
  private float m_reflect;

  Material( Color ambient, Color diffuse )
  {
    this( ambient, diffuse, null, 0, 0 );
  }
  
  Material( Color ambient, Color diffuse, Color shiny, float power, float reflect )
  {
    m_ambient = ambient;
    m_diffuse = diffuse;
    m_specular = shiny;
    m_power = power;
    m_reflect = reflect;
  }
  
  public Color diffuse() { return m_diffuse; }
  public Color ambient() { return m_ambient; } 
  public Color specular() { return m_specular; }
  public float power() { return m_power; }
  public float reflectConst() { return m_reflect; }
}
