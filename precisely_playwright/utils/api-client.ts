import axios from 'axios';
import dotenv from 'dotenv';

dotenv.config();

export class PreciselyAPIClient {
  private accessToken = '';
  private tokenExpiry = 0;
  private baseURL = process.env.API_BASE_URL || 'https://api.precisely.com';
  private clientId = process.env.CLIENT_ID || '';
  private clientSecret = process.env.CLIENT_SECRET || '';

  async getAccessToken(): Promise<string> {
    if (this.accessToken && Date.now() < this.tokenExpiry) return this.accessToken;

    const auth = Buffer.from(`${this.clientId}:${this.clientSecret}`).toString('base64');
    const res = await axios.post(`${this.baseURL}/oauth/token`, 'grant_type=client_credentials', {
      headers: { 'Authorization': `Basic ${auth}`, 'Content-Type': 'application/x-www-form-urlencoded' }
    });

    this.accessToken = res.data.access_token;
    this.tokenExpiry = Date.now() + (res.data.expiresIn - 300) * 1000;
    return this.accessToken;
  }

  async get(endpoint: string, params?: any) {
    const token = await this.getAccessToken();
    return axios.get(`${this.baseURL}${endpoint}`, {
      headers: { 'Authorization': `Bearer ${token}` },
      params
    });
  }

  async post(endpoint: string, data?: any) {
    const token = await this.getAccessToken();
    return axios.post(`${this.baseURL}${endpoint}`, data, {
      headers: { 'Authorization': `Bearer ${token}` }
    });
  }
}

export const apiClient = new PreciselyAPIClient();
