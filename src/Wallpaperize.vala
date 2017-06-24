using Cairo;

public class Wallpaperize.Wallpaperiser : Object {
    public static int W = 1920;
    public static int H = 1080;
    private const int RADIUS = 3;

    private static Gdk.Pixbuf image;

    private static int width;
    private static int height;
    private static double zoom;

    public static void from_file (File file) {
      var path = file.get_path ();
      try {
          var file_regex = new GLib.Regex (".(jpe?g|png|tiff|gif)$");
          string output_name = file_regex.replace (path, path.length, 0,"") + ".wp.png";
          make_image (path, output_name);
          set_wallpaper (output_name);
      } catch (RegexError e) {
          stdout.printf ("Error on file: %s", e.message);
      }
    }

    public static void get_monitor_geometry() {
        Gdk.Screen screen = Gdk.Screen.get_default();
        int primary_monitor = screen.get_primary_monitor();
        Gdk.Rectangle geometry;
        screen.get_monitor_geometry(primary_monitor, out geometry);

        int monitor_scale = screen.get_monitor_scale_factor(primary_monitor);
        Wallpaperize.Wallpaperiser.H = geometry.height * monitor_scale;
        Wallpaperize.Wallpaperiser.W = geometry.width * monitor_scale;
    }

    // from switchboard-plug-pantheon-shell set-wallpaper.vala
    public static void set_wallpaper (string uri) {
        var settings = new Settings ("org.gnome.desktop.background");
        settings.set_string ("picture-uri", uri);
        settings.apply ();
        Settings.sync ();
    }

    public static void make_image (string input, string output) {
        var surface = make_surface (input);
        surface.surface.write_to_png (output);
    }

    public static Granite.Drawing.BufferSurface? make_surface (string input) {
        var surface = new Granite.Drawing.BufferSurface (W, H);
        try {
            image = new Gdk.Pixbuf.from_file (input);
        } catch (Error e) {
            stderr.printf ("Error on input: %s", e.message);
            return null;
        }

        width = image.get_width();
        height = image.get_height();

        //Scale image if too big
        if (width > W || height > H) {
            while (width > W || height > H) {
                width = width / 5 * 2;
                height = height / 5 * 2;
            }

            image = image.scale_simple (width, height, Gdk.InterpType.BILINEAR);
        }

        int center_h = H/2 - height/2;
        int center_w = W/2 - width/2;
        double zoomh = H / (double) height;
        double zoomw = W / (double) width;

        if (zoomw >= zoomh) {
            zoom = zoomw;
        } else {
            zoom = zoomh;
        }

        //Background
        Gdk.cairo_set_source_pixbuf (surface.context, image, 0, 0);
        surface.context.scale (zoom, zoom);
        surface.context.paint ();

        //Lighten background
        surface.context.set_source_rgba (0,0,0, 0.1);
        surface.context.paint ();

        //Blur
        surface.exponential_blur (55);
        surface.context.paint ();

        //Draw shadow
        surface.context.scale (1/zoom, 1/zoom);

        surface.context.move_to (center_w + RADIUS, center_h);
        surface.context.arc (center_w + width - RADIUS  , center_h + RADIUS, RADIUS, Math.PI * 1.5, Math.PI * 2);
        surface.context.arc (center_w + width - RADIUS  , center_h + height - RADIUS + 2, RADIUS,  0, Math.PI * 0.5);
        surface.context.arc (center_w + RADIUS, center_h + height - RADIUS + 2 , RADIUS, Math.PI * 0.5, Math.PI);
        surface.context.arc (center_w + RADIUS, center_h + RADIUS, RADIUS, Math.PI, Math.PI * 1.5);
        surface.context.close_path ();

        surface.context.set_line_width (7.0);
        surface.context.set_source_rgba (0, 0, 0, 0.4);
        surface.context.fill_preserve ();

        surface.exponential_blur (5);

        //Place image
        Granite.Drawing.Utilities.cairo_rounded_rectangle (surface.context, center_w, center_h, image.get_width(), image.get_height(), RADIUS);
        Gdk.cairo_set_source_pixbuf (surface.context, image, center_w, center_h);
        surface.context.fill_preserve ();

        return surface;
    }
}
