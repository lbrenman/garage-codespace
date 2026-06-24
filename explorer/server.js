const express = require('express');
const multer = require('multer');
const {
  S3Client,
  ListBucketsCommand,
  ListObjectsV2Command,
  CreateBucketCommand,
  DeleteBucketCommand,
  DeleteObjectCommand,
  GetObjectCommand,
  PutObjectCommand,
} = require('@aws-sdk/client-s3');
const { getSignedUrl } = require('@aws-sdk/s3-request-presigner');
const path = require('path');

const app = express();
const upload = multer({ storage: multer.memoryStorage() });
app.use(express.json());
app.use(express.static(path.join(__dirname, 'public')));

// S3 client — reads env vars set by .awsrc / start.sh
const s3 = new S3Client({
  endpoint: process.env.AWS_ENDPOINT_URL || 'http://localhost:3900',
  region: process.env.AWS_DEFAULT_REGION || 'garage',
  credentials: {
    accessKeyId: process.env.AWS_ACCESS_KEY_ID,
    secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY,
  },
  forcePathStyle: true,
});

// ── Config ───────────────────────────────────────────────────────────────────
app.get('/api/config', (req, res) => {
  res.json({ endpoint: process.env.AWS_ENDPOINT_URL || 'http://localhost:3900' });
});

// ── Buckets ─────────────────────────────────────────────────────────────────
app.get('/api/buckets', async (req, res) => {
  try {
    const data = await s3.send(new ListBucketsCommand({}));
    res.json(data.Buckets || []);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.post('/api/buckets', async (req, res) => {
  try {
    const { name } = req.body;
    await s3.send(new CreateBucketCommand({ Bucket: name }));
    res.json({ ok: true });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.delete('/api/buckets/:bucket', async (req, res) => {
  try {
    await s3.send(new DeleteBucketCommand({ Bucket: req.params.bucket }));
    res.json({ ok: true });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// ── Objects ──────────────────────────────────────────────────────────────────
app.get('/api/buckets/:bucket/objects', async (req, res) => {
  try {
    const data = await s3.send(new ListObjectsV2Command({
      Bucket: req.params.bucket,
      Prefix: req.query.prefix || '',
      Delimiter: '/',
    }));
    res.json({
      objects: data.Contents || [],
      prefixes: (data.CommonPrefixes || []).map(p => p.Prefix),
    });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.post('/api/buckets/:bucket/upload', upload.single('file'), async (req, res) => {
  try {
    const prefix = req.body.prefix || '';
    const key = prefix + req.file.originalname;
    await s3.send(new PutObjectCommand({
      Bucket: req.params.bucket,
      Key: key,
      Body: req.file.buffer,
      ContentType: req.file.mimetype,
    }));
    res.json({ ok: true, key });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.delete('/api/buckets/:bucket/objects', async (req, res) => {
  try {
    const { key } = req.body;
    await s3.send(new DeleteObjectCommand({ Bucket: req.params.bucket, Key: key }));
    res.json({ ok: true });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.get('/api/buckets/:bucket/download', async (req, res) => {
  try {
    const url = await getSignedUrl(s3, new GetObjectCommand({
      Bucket: req.params.bucket,
      Key: req.query.key,
    }), { expiresIn: 300 });
    res.json({ url });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

const PORT = process.env.EXPLORER_PORT || 3910;
app.listen(PORT, () => console.log(`Garage Explorer running at http://localhost:${PORT}`));
