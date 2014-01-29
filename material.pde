class Material
{
  private Color m_ambient;
  private Color m_diffuse;

  Material( Color ambient, Color diffuse )
  {
    m_ambient = ambient;
    m_diffuse = diffuse;
  }
  
  public Color getDiffuse() { return m_diffuse; }
  public Color getAmbient() { return m_ambient; } 
}
