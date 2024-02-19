import * as esbuild from 'esbuild';
import autoprefixer from 'autoprefixer';
import tailwindcss from 'tailwindcss';
import postcss from 'esbuild-plugin-postcss2';
import { minifyHTMLLiteralsPlugin } from 'esbuild-plugin-minify-html-literals';

const dev = process.env.NODE_ENV !== "production";


export default await esbuild.context({
  entryPoints: ["./js/index.js"],
  bundle: true,
  minify: !dev,
  sourcemap: dev,
  legalComments: "linked",
  outdir: "../_site",
  plugins: [
    minifyHTMLLiteralsPlugin(),
    postcss.default({
      plugins: [
        tailwindcss,
        autoprefixer,
      ],
    }),
  ]
});
