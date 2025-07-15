import multiparty from 'multiparty';
import fs from 'fs';

export const config = {
  api: {
    bodyParser: false,
  },
};

export default function handler(req, res) {
  const form = new multiparty.Form();
  form.parse(req, (err, fields, files) => {
    if (err) {
      console.error(err);
      return res.status(500).send('Parse error');
    }
    const uploaded = files.datafile?.[0];
    if (!uploaded) {
      return res.status(400).send('No file uploaded');
    }

    fs.readFile(uploaded.path, (err, data) => {
      if (err) {
        console.error(err);
        return res.status(500).send('Read error');
      }
      // MVP: just report size
      res.status(200).send(`Received ${data.length} bytes`);
    });
  });
}
