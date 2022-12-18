String currentPexelsApiKey = '563492ad6f91700001000001f35339eaf5d743f4af32609d915984df';
String alternatePexelsApiKey = '563492ad6f91700001000001f35339eaf5d743f4af32609d915984df'; // todo change api key later
String _temp = '';

void swapKeys() {
  _temp = currentPexelsApiKey;
  currentPexelsApiKey = alternatePexelsApiKey;
  alternatePexelsApiKey = _temp;
}
