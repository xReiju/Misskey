"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
/**
 * Module dependencies
 */
const cafy_1 = require("cafy");
const post_1 = require("../../../models/post");
/**
 * Aggregate repost of a post
 *
 * @param {any} params
 * @return {Promise<any>}
 */
module.exports = (params) => new Promise(async (res, rej) => {
    // Get 'post_id' parameter
    const [postId, postIdErr] = cafy_1.default(params.post_id).id().$;
    if (postIdErr)
        return rej('invalid post_id param');
    // Lookup post
    const post = await post_1.default.findOne({
        _id: postId
    });
    if (post === null) {
        return rej('post not found');
    }
    const datas = await post_1.default
        .aggregate([
        { $match: { repost_id: post._id } },
        { $project: {
                created_at: { $add: ['$created_at', 9 * 60 * 60 * 1000] } // Convert into JST
            } },
        { $project: {
                date: {
                    year: { $year: '$created_at' },
                    month: { $month: '$created_at' },
                    day: { $dayOfMonth: '$created_at' }
                }
            } },
        { $group: {
                _id: '$date',
                count: { $sum: 1 }
            } }
    ]);
    datas.forEach(data => {
        data.date = data._id;
        delete data._id;
    });
    const graph = [];
    for (let i = 0; i < 30; i++) {
        let day = new Date(new Date().setDate(new Date().getDate() - i));
        const data = datas.filter(d => d.date.year == day.getFullYear() && d.date.month == day.getMonth() + 1 && d.date.day == day.getDate())[0];
        if (data) {
            graph.push(data);
        }
        else {
            graph.push({
                date: {
                    year: day.getFullYear(),
                    month: day.getMonth() + 1,
                    day: day.getDate()
                },
                count: 0
            });
        }
    }
    res(graph);
});
