/* eslint-disable no-console */
export default (function (o, c, d) {
  if (!process || process.env.NODE_ENV !== 'production') {
    var proto = c.prototype;
    var oldParse = proto.parse;

    proto.parse = function (cfg) {
      var date = cfg.date;

      if (typeof date === 'string' && date.length === 13) {
        console.warn("To parse a Unix timestamp like " + date + ", you should pass it as a Number. https://day.js.org/docs/en/parse/unix-timestamp-milliseconds");
      }

      if (cfg.args.length >= 2 && !d.p.customParseFormat) {
        console.warn("To parse a date-time string like " + date + " using the given format, you should enable customParseFormat plugin first. https://day.js.org/docs/en/parse/string-format");
      }

      return oldParse.bind(this)(cfg);
    };
  }
});