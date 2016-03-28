# phylify

To make visNetwork full screen, create a bookmark on your bookmarks bar and put
this in the URL:

```js
javascript:(() => { const styles=document.createElement('style');  styles.innerHTML = 'body { padding: 0 !important; } html, body, #htmlwidget_container, .visNetwork { height: 100% !important; }'; document.body.appendChild(styles) })()
```

Then you can click it whenever you are viewing a visNetwork.

The code is a *self-executing anonymous function*, not in one line:
```js
(() => {
  const styles = document.createElement('style');
  styles.innerHTML = 'body { padding: 0 !important; } html, body, #htmlwidget_container, .visNetwork { height: 100% !important; }';   document.body.appendChild(styles)
})()
```
