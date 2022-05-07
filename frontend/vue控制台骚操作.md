B站发弹幕
```javascript
$('#control-panel-ctnr-box').__vue__.$data.chatInput = "加油";
$('#control-panel-ctnr-box').__vue__.sendDanmaku()
```
表单元素修改
```javascript
$("form元素").__vue__.model.XXX
```
常规元素修改
```text
$("表单组件").parentNode(若干个).__vue__.(找对应属性)
```