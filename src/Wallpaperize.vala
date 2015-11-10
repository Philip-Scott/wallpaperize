using Cairo;

public class Wallpaperize : Object {
    private const int W = 1920;
    private const int H = 1080;
    private const int RADIUS = 12;

    private Gdk.Pixbuf image;

    private int width;
    private int height;
    private double zoom;

    public int make_image (string input, string output) {
        var surface = new Granite.Drawing.BufferSurface (W, H);
        try {
            image = new Gdk.Pixbuf.from_file (input);
        } catch (Error e) {
            stderr.printf ("Error on input: %s", e.message);
            return 1;
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

        surface.surface.write_to_png (output);

        return 0;
    }

    public static int main (string[] argv) {
        var wallpaper_maker = new Wallpaperize ();
        if (argv.length >= 2) {
            int n = 0;
            foreach (string file in argv) {
                if (n++ == 0) {
                    continue;
                }
                string output_name = file.replace (".png", "").replace (".jpg", "") + ".wp.png";
                wallpaper_maker.make_image (file, output_name);
            }
        } else {
            stderr.printf ("Usage: %s <images> %d\n", argv[1], argv.length);
            return 1;
        }
        return 0;
    }
}
