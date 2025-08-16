# Notes Web

List non-standard (unique) keys on window:

```js
((w,d,f=d.createElement("iframe"))=>(d.body.appendChild(f),console.log(Object.getOwnPropertyNames(w).filter(k=>!Object.hasOwnProperty.call(f.contentWindow,k))),d.body.removeChild(f)))(window,document)
```
