import axios from 'axios'

const baseUrl = 'http://localhost/BIRDZ/back/api/todo/'
const headers = { 'content-type': 'application/x-www-form-urlencoded' }

export const callApi = ((method, type, data) => {
	return axios({
		method: method,
		url: baseUrl + type,
		headers: headers,
		data: data
	})
})