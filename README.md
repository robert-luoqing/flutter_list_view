## Flutter List View

I don't like official list view. There are some features don't provide and jumpTo performance is not good. I rewrite the list supported these features in [Features] sections

## Features

1. Support jump to index
   Jump to index is not support in listview. But it is useful function 
2. Support keep position
   If some data insert before other items, It will scroll down. Some chat software may want to keep the position not scroll down when new message coming.
3. Support show top in reverse model if the data can't fill full viewport.
4. Performance
   When listview jump to somewhere, The items which layout before the position will always loaded. It is not realy lazy loading.


## Screen

