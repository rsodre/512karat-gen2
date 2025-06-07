use core::byte_array::ByteArrayTrait;
use core::array::{Array, ArrayTrait};
use karat_gen2::models::{
    seed::{Seeder, SeederTrait},
    gen2::{
        props::{Gen2Props},
        class::{ClassTrait},
        palette::{PaletteTrait},
    },
};
use karat_gen2::utils::misc::{safe_sub};

const GAP: usize = 6;
const WIDTH: usize = (12 * 3);
const HEIGHT: usize = (12 * 4);

#[generate_trait]
pub impl Gen2RendererImpl of Gen2RendererTrait {

    //------------------------
    // SVG builder
    //
    fn render_svg(token_props: @Gen2Props) -> ByteArray {
        //---------------------------
        // get props
        //
        let font_name: ByteArray = token_props.class.font_name();
        let char_set: Span<felt252> = token_props.class.get_char_set();
        let char_set_lengths: Span<usize> = token_props.class.get_char_set_lengths();
        let (text_length, text_scale): (usize, ByteArray) = token_props.class.get_text_size();
        let (color_bg, color_ink, color_shadow): (ByteArray, ByteArray, ByteArray) = token_props.palette.get_colors();
        //---------------------------
        // Build SVG
        //
        let mut result: ByteArray = "";
        let _WIDTH: usize = (GAP + WIDTH + GAP);
        let _HEIGHT: usize = (GAP + HEIGHT + GAP);
        let RES_X: usize = _WIDTH * 20;     // 960
        let RES_Y: usize = _HEIGHT * 20;    // 1200
        result.append(@format!(
            "<svg xmlns=\"http://www.w3.org/2000/svg\" xmlns:xlink=\"http://www.w3.org/1999/xlink\" version=\"1.1\" width=\"{}\" height=\"{}\" viewBox=\"-{} -{} {} {}\">",
                RES_X,
                RES_Y,
                GAP,
                GAP,
                _WIDTH,
                _HEIGHT,
        ));
        //
        // styles
        let shadow_style: ByteArray =
            if (color_shadow.len() != 0) {format!("text-shadow:0.8px 0.8px {};", color_shadow)}
            else {""};
        result.append(@format!(
            "<style>.BG{{fill:{};}}text{{fill:{};font-size:1px;font-family:'{}';{}transform:scaleX({});letter-spacing:0;dominant-baseline:hanging;shape-rendering:crispEdges;white-space:pre;cursor:default;-webkit-user-select:none;-moz-user-select:none;-ms-user-select:none;user-select:none;}}</style>",
                color_bg,
                color_ink,
                font_name,
                shadow_style,
                text_scale,
        ));
        result.append(@format!(
            "<g><rect class=\"BG\" x=\"-{}\" y=\"-{}\" width=\"{}\" height=\"{}\" /><g>",
                GAP,
                GAP,
                _WIDTH,
                _HEIGHT,
        ));
        //---------------------------
        // Build text tags
        //
        let char_count: usize = char_set.len();
        let cells: Span<usize> = Self::_make_cells(*token_props.seed, char_count);
        let mut y: usize = 0;
        loop {
            if (y == HEIGHT) { break; }
            // open <text>
            result.append(@format!(
                "<text y=\"{}\" textLength=\"{}\">",
                    y,
                    text_length,
            ));
            let mut x: usize = 0;
            loop {
                if (x == WIDTH) { break; }
                let value: @usize = cells.at(y * WIDTH + x);
                result.append_word(*char_set.at(*value), *char_set_lengths.at(*value));
                x += 1;
            };
            // close <text>
            result.append(@"</text>");
            y += 1;
        };
        //----------------
        // close it!
        //
        result.append(@"</g></g></svg>");
        (result)
    }


    //------------------------
    // token cell builder
    //
    fn _make_cells(seed: u256, char_count: usize) -> Span<usize> {
        let mut seeder: Seeder = SeederTrait::new(seed);
        // seed params
        let HALF_W: usize = (WIDTH / 2);
        let HALF_H: usize = (HEIGHT / 2);
        let sc_x: usize = seeder.get_next(HALF_W);
        let sc_y = sc_x * seeder.get_next(3);
        let off_x: usize = seeder.get_next(HALF_W);
        let off_y: usize = seeder.get_next(HALF_H);
        let mod_x: usize = 1 + seeder.get_next(char_count);
        let mod_y: usize = 1 + seeder.get_next(char_count);
        let fade_type: usize = seeder.get_next(6);
        let fade_amount: usize = 1 + seeder.get_next(4);
        // build cells
        let mut cells:Array<usize> = array![];
        let mut y: usize = 0;
        loop {
            if (y == HEIGHT) { break; }
            let norm_y: usize = if (y < HALF_H) {y} else {HEIGHT - y};
            let mut x: usize = 0;
            loop {
                if (x == WIDTH) { break; }
                let norm_x: usize = if (x < HALF_W) {x} else {WIDTH - x};
                let mut value: usize = 0;

                if (x < HALF_W) {
                    // generate LEFT
                    value = (
                        (x * sc_x) + off_x + (x % mod_x) +
                        (y * sc_y) + off_y + (y % mod_y)
                    ) % char_count;
                    // fade out borders
                    let mut f: usize = 0;
                    if (fade_type == 1 && (x + norm_y) > HALF_H) { // inside-out
                        let fy = (norm_y - HALF_H);
                        f = ((x + fy) / fade_amount);
                    } else if (fade_type == 2 && (x + norm_y) < HALF_H) { // inverted border
                        f = ((x + norm_y) / fade_amount) * 2;
                    } else if (fade_type == 3 ) { // top/bottom v2
                        f = (safe_sub(HALF_H, norm_y) / fade_amount);
                    } else if (fade_type == 4 ) { // top/bottom
                        f = (safe_sub(norm_y, HALF_H) / fade_amount);
                    } else if (fade_type == 5 ) { // sides
                        f = (safe_sub(HALF_W, norm_x) / fade_amount);
                    }
                    if (f > 0) {
                        value = safe_sub(value, f);
                    }
                } else {
                    // mirror LEFT>RIGHT
                    value = *cells.at(y*WIDTH + (WIDTH-x-1));
                }
                cells.append(value);
                x += 1;
            };
            y += 1;
        };
        (cells.span())
    }
}



//----------------------------
// tests
//
#[cfg(test)]
mod unit {
    use super::{Gen2RendererTrait};
    use karat_gen2::models::gen2::{
        props::{Gen2Props},
        class::{Class, ClassTrait},
        palette::{PaletteTrait},
    };
    use karat_gen2::utils::hash::{make_seed};
    use karat_gen2::tests::tester::tester::{OWNER};

    fn _name_class_props(class: Class, token_id: u128) -> Gen2Props {
        let seed: u256 = make_seed(OWNER(), token_id).into();
        (Gen2Props {
            token_id,
            seed,
            class,
            palette: PaletteTrait::randomize(seed),
            realm_id: token_id,
            attributes: [].span(),
        })
    }

    fn _dump_class_svg(class: Class) {
        // let i: u128 = class.into();
        // let props = _name_class_props(class, (i+1));
        // let svg = Gen2RendererTrait::render_svg(@props);
        // println!("____SVG[{}][{}]:{}", i, class.name(), svg);
    }

    #[test]
    #[ignore]
    fn test_class_svgs() {
        let mut i: u128 = 0;
        loop {
            let class: Class = i.into();
            if (class == Class::Count) { break; }
            _dump_class_svg(class);
            i += 1;
        }
    }

    #[test]
    fn test_class_a() { _dump_class_svg(Class::A); }
    #[test]
    fn test_class_b() { _dump_class_svg(Class::B); }
    #[test]
    fn test_class_c() { _dump_class_svg(Class::C); }
    #[test]
    fn test_class_d() { _dump_class_svg(Class::D); }
    #[test]
    fn test_class_e() { _dump_class_svg(Class::E); }
    #[test]
    fn test_class_g() { _dump_class_svg(Class::G); }
    #[test]
    fn test_class_h() { _dump_class_svg(Class::H); }
    #[test]
    fn test_class_v() { _dump_class_svg(Class::V); }
    #[test]
    fn test_class_l() { _dump_class_svg(Class::L); }

}
