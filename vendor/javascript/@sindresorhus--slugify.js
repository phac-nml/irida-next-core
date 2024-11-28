// @sindresorhus/slugify@2.2.1 downloaded from https://ga.jspm.io/npm:@sindresorhus/slugify@2.2.1/index.js

import e from"escape-string-regexp";import r from"@sindresorhus/transliterate";const t=[["&"," and "],["🦄"," unicorn "],["♥"," love "]];const decamelize=e=>e.replace(/([A-Z]{2,})(\d+)/g,"$1 $2").replace(/([a-z\d]+)([A-Z]{2,})/g,"$1 $2").replace(/([a-z\d])([A-Z])/g,"$1 $2").replace(/([A-Z]+)([A-Z][a-rt-z\d]+)/g,"$1 $2");const removeMootSeparators=(r,t)=>{const s=e(t);return r.replace(new RegExp(`${s}{2,}`,"g"),t).replace(new RegExp(`^${s}|${s}$`,"g"),"")};const buildPatternSlug=r=>{let t="a-z\\d";t+=r.lowercase?"":"A-Z";if(r.preserveCharacters.length>0)for(const s of r.preserveCharacters){if(s===r.separator)throw new Error(`The separator character \`${r.separator}\` cannot be included in preserved characters: ${r.preserveCharacters}`);t+=e(s)}return new RegExp(`[^${t}]+`,"g")};function slugify(e,s){if("string"!==typeof e)throw new TypeError(`Expected a string, got \`${typeof e}\``);s={separator:"-",lowercase:true,decamelize:true,customReplacements:[],preserveLeadingUnderscore:false,preserveTrailingDash:false,preserveCharacters:[],...s};const a=s.preserveLeadingUnderscore&&e.startsWith("_");const n=s.preserveTrailingDash&&e.endsWith("-");const o=new Map([...t,...s.customReplacements]);e=r(e,{customReplacements:o});s.decamelize&&(e=decamelize(e));const c=buildPatternSlug(s);s.lowercase&&(e=e.toLowerCase());e=e.replace(/([a-zA-Z\d]+)'([ts])(\s|$)/g,"$1$2$3");e=e.replace(c,s.separator);e=e.replace(/\\/g,"");s.separator&&(e=removeMootSeparators(e,s.separator));a&&(e=`_${e}`);n&&(e=`${e}-`);return e}function slugifyWithCounter(){const e=new Map;const countable=(r,t)=>{r=slugify(r,t);if(!r)return"";const s=r.toLowerCase();const a=e.get(s.replace(/(?:-\d+?)+?$/,""))||0;const n=e.get(s);e.set(s,"number"===typeof n?n+1:1);const o=e.get(s)||2;(o>=2||a>2)&&(r=`${r}-${o}`);return r};countable.reset=()=>{e.clear()};return countable}export{slugify as default,slugifyWithCounter};
