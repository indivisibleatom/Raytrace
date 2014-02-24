class SceneBuilder
{
  Scene m_scene;
  ArrayList<Point> m_verticesCached;
  
  SceneBuilder()
  {
    m_scene = new Scene();
  }
  
  private void setCameraFov(int angle)
  {
    m_scene.setCameraFov(angle);
  }
  
  private void setBackgroundColor(Color bgColor)
  {
    m_scene.setBackgroundColor(bgColor);
  }
  
  private void addPointLight(Point location, Color col)
  {
    m_scene.addPointLight(location, col);
  }
  
  private void raytrace()
  {
    m_scene.raytrace();
  }
  
  private void addNamedObject(String name)
  {
    m_scene.addNamedObject(name);
  }
  
  private void instantiateObject(String name)
  {
    m_scene.instantiateObject(name);
  }
  
  private void startPolygon()
  {
    m_verticesCached = new ArrayList<Point>();
  }
  
  private void addVertex( Point vertex )
  {
    m_verticesCached.add( vertex );
  }
  
  private void endPolygon()
  {
    Triangle t = new Triangle( m_verticesCached.get(0), m_verticesCached.get(1), m_verticesCached.get(2),  m_scene.getCurrentTransformation() );
    m_scene.addObject( new GeometricPrimitive( t, m_scene.getCurrentMaterial() ) );
  }
  
  private void addSphere( float radius, Point center )
  {
    //TODO msati3: Add radius and center into the transformation of the object
    Sphere s = new Sphere( radius, center, m_scene.getCurrentTransformation() );
    m_scene.addObject( new GeometricPrimitive( s, m_scene.getCurrentMaterial() ) );
  }
  
  private void addBox( Point p1, Point p2 )
  {
    Box b = new Box( p1, p2, m_scene.getCurrentTransformation() );
    m_scene.addObject( new GeometricPrimitive( b, m_scene.getCurrentMaterial() ) );
  }
  
  private void setTranslate( Vector translation )
  {
    m_scene.translate( translation );
  }
  
  private void setScale( Vector scale )
  {
    m_scene.scale( scale );
  }
  
  private void setRotate( float angle, Vector axis )
  {
    angle = angle * PI / 180;
    m_scene.rotate( angle, axis );
  }
 
  private void setCoeffs( float[] ambientCoeffs, float[] diffuse )
  {
    m_scene.setCoeffs( new Color( ambientCoeffs ), new Color( diffuse ) );
  }
   
  void buildScene(String fileName)
  {
    int timer = 0;
    String str[] = loadStrings(fileName);
    if (str == null) 
    {
      println("Error! Failed to read the file.");
    }

    for (int i=0; i<str.length; i++) 
    {     
      String[] token = splitTokens(str[i], " "); // Get a line and parse tokens.
      if (token.length == 0) continue; // Skip blank line.
      
      if (token[0].equals("fov"))
      {
        int angle = Integer.parseInt(token[1]);
        setCameraFov(angle);
      }
      else if (token[0].equals("background")) 
      {
        //TODO msati3: Create functions for parsing such tuples?
        Color bgColor = new Color( Float.parseFloat(token[1]), Float.parseFloat(token[2]), Float.parseFloat(token[3]) );
        setBackgroundColor(bgColor);
      }
      else if (token[0].equals("point_light")) 
      {
        Point location = new Point( Float.parseFloat(token[1]), Float.parseFloat(token[2]), Float.parseFloat(token[3]) );
        Color col = new Color( Float.parseFloat(token[4]), Float.parseFloat(token[5]), Float.parseFloat(token[6]) );
        addPointLight(location, col);
      }
      else if (token[0].equals("diffuse"))
      {
        float[] diffuseCoeffs = {Float.parseFloat(token[1]), Float.parseFloat(token[2]), Float.parseFloat(token[3])};
        float[] ambientCoeffs = {Float.parseFloat(token[4]), Float.parseFloat(token[5]), Float.parseFloat(token[6])};
        setCoeffs( ambientCoeffs, diffuseCoeffs );
      } 
      else if (token[0].equals("begin")) 
      {
        startPolygon();
      }
      else if (token[0].equals("end")) 
      {
        endPolygon();
      }
      else if (token[0].equals("named_object"))
      {
        addNamedObject(token[1]);
      }
      else if (token[0].equals("instance"))
      {
        instantiateObject(token[1]);
      }
      else if (token[0].equals("vertex")) 
      {
        addVertex( new Point( Float.parseFloat(token[1]), Float.parseFloat(token[2]), Float.parseFloat(token[3]) ) );
      }
      else if (token[0].equals("sphere")) 
      {
        float radius = Float.parseFloat(token[1]);
        Point center = new Point( Float.parseFloat(token[2]), Float.parseFloat(token[3]), Float.parseFloat(token[4]) );
        addSphere(radius, center);
      }
      else if (token[0].equals("box"))
      {
        Point p1 = new Point( Float.parseFloat(token[1]), Float.parseFloat(token[2]), Float.parseFloat(token[3]) );
        Point p2 = new Point( Float.parseFloat(token[4]), Float.parseFloat(token[5]), Float.parseFloat(token[6]) );
        addBox(p1, p2);
      }
      else if (token[0].equals("begin_list"))
      {
        m_scene.startList();
      }
      else if (token[0].equals("end_list"))
      {
        m_scene.commitList();
      }
      else if (token[0].equals("end_accel"))
      {
        m_scene.commitAccel();
      }
      else if (token[0].equals("push"))
      {
        m_scene.onPush();
      }
      else if (token[0].equals("pop"))
      {
        m_scene.onPop();
      }
      else if (token[0].equals("translate"))
      {
        Vector translate = new Vector( Float.parseFloat(token[1]), Float.parseFloat(token[2]), Float.parseFloat(token[3]) );
        setTranslate( translate );
      }
      else if (token[0].equals("rotate"))
      {
        Vector rotateAxis = new Vector( Float.parseFloat(token[2]), Float.parseFloat(token[3]), Float.parseFloat(token[4]) );
        float rotateAngle = Float.parseFloat(token[1]);
        setRotate( rotateAngle, rotateAxis );
      }  
      else if (token[0].equals("scale"))
      {
        Vector scaleFactor = new Vector( Float.parseFloat(token[1]), Float.parseFloat(token[2]), Float.parseFloat(token[3]) );
        setScale( scaleFactor );
      }
      else if (token[0].equals("read"))
      {
        buildScene(token[1]);
      }
      else if (token[0].equals("reset_timer")) 
      {
        timer = millis();
      }
      else if (token[0].equals("print_timer")) 
      {
        int new_timer = millis();
        int diff = new_timer - timer;
        float seconds = diff / 1000.0;
        println ("Timer = " + seconds);
      }
      else if (token[0].equals("write")) 
      {
        // save the current image to a .png file
        raytrace();
        save(token[1]);
      }
     
      //Debug parser debug code
      else if (token[0].equals("color")) 
      {
        Color col = new Color( Float.parseFloat(token[1]), Float.parseFloat(token[2]), Float.parseFloat(token[3]) );
        fill(col.R(), col.G(), col.B());
      }
      else if (token[0].equals("rect")) 
      {
        float x0 = float(token[1]);
        float y0 = float(token[2]);
        float x1 = float(token[3]);
        float y1 = float(token[4]);
        rect(x0, screen_height-y1, x1-x0, y1-y0);
      }
    }
  }
}
