import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MediaMetadata extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String artist;

  const MediaMetadata({
    Key? key,
    required this.imageUrl,
    required this.title,
    required this.artist,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
            child: Container(
              color: Colors.black,
              child: Stack(
                children: [
                  //back button
                  Positioned(
                    top: 20,
                    left: 10,
                    child: IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),

                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      //thumbnail image
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 50.0,
                          right: 50.0,
                          bottom: 15.0,
                          top: 150.0,
                        ),
                        child: ClipRRect(
                          child: CachedNetworkImage(
                            imageUrl: imageUrl ??
                                'https://i.ytimg.com/vi/5qap5aO4i9A/maxresdefault.jpg',
                            placeholder: (context, url) =>
                                CircularProgressIndicator(),
                            errorWidget: (context, url, error) =>
                                Icon(Icons.error, color: Colors.white),
                              imageBuilder: (context, imageProvider) => Container(
                                height: 250.0,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(50), // Add this line
                                  image: DecorationImage(
                                      image: imageProvider, fit: BoxFit.cover),
                                ),
                              )
                          ),
                        ),
                      ),
                      //title text
                      Text(
                        title,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      //author text
                      Text(
                        artist,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontFamily: 'JosefinSans'),
                      ),
                      SizedBox(height: 16),
                     
                    
                    ],
                  ),
                ],
              ),
            ));
  }
}
