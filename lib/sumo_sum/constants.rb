TOP_CLASSES=' started |' +
  ' parse regex "\s(?<protocol>.+)\s\"(?<pre>/.*)\" "|' +
  'where !(pre matches  "*png*")|' +
  'where !(pre matches "*/assets*")|' +
  'where !(pre matches "*page=*" ) |' +
  "split pre delim='/' extract 2 as class, 3 as method, 4 as id |" +
  "split class delim='?' extract 1 as class |" +
  "split method delim='?' extract 1 as method |" +
  'replace(method,"9","0") as method |' +
  'replace(method,"8","0") as method |' +
  'replace(method,"7","0") as method |' +
  'replace(method,"6","0") as method |' +
  'replace(method,"5","0") as method |' +
  'replace(method,"4","0") as method |' +
  'replace(method,"3","0") as method |' +
  'replace(method,"2","0") as method |' +
  'replace(method,"1","0") as method |' +
  'replace(method,"00000","0") as method |' + 
  'replace(method,"0000","0") as method |' + 
  'replace(method,"000","0") as method |' + 
  'replace(method,"00","0") as method |' + 
  'replace(method,"0",":id") as method |' + 
  'count_frequent class,method,protocol'
