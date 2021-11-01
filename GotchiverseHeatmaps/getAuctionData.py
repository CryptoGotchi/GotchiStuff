# Get parcel auction data from the subgraph
# Quick and dirty, please don't judge ^^'
# -CryptoGotchi

import json
import time
import numpy as np
import requests

subgraph = {
    'url': 'https://api.thegraph.com/subgraphs/name/aavegotchi/aavegotchi-realm-matic',
    'query': '{"query": "{ auctions(first: 1000, where: {tokenId_gt: %d}, orderBy: tokenId) { highestBid tokenId parcelSize }}"}',
    'query2': '{"query": "{ parcels(first: 1000, where: {tokenId_gt: %d}, orderBy: tokenId) { district tokenId size coordinateX coordinateY }}"}',
    'headers': {'Content-Type': 'application/json'}
}

numParcels = 16000
ind = 0
parcels = {}
numQueries = int(numParcels / 1000)
maxTokenId = 0
for i in range(numQueries):
    print(f'Query {i+1} of {numQueries}')
    datastring = subgraph['query'] % maxTokenId
    response = requests.post(subgraph['url'], data=datastring, headers=subgraph['headers'], timeout=20).json()
    numReturns = len(response['data']['auctions'])
    for j in range(numReturns):
        tokenId = response['data']['auctions'][j]['tokenId']
        parcels[tokenId] = {}
        parcels[tokenId]['highestBid'] = response['data']['auctions'][j]['highestBid']
        parcels[tokenId]['parcelSize'] = response['data']['auctions'][j]['parcelSize']
        # There are 2 different "sizes" for spacious parcels (vertical and horizontal).
        # Here we just want to know if it is spacious (parcelSize)
        # Orientation will still be encoded in "size" down below
        if int(parcels[tokenId]['parcelSize']) == 3:
            parcels[tokenId]['parcelSize'] = '2'
        maxTokenId = int(tokenId)
        ind += 1
    time.sleep(2)

maxTokenId = 0
for i in range(numQueries):
    print(f'Query {i+1} of {numQueries}')
    datastring = subgraph['query2'] % maxTokenId
    response = requests.post(subgraph['url'], data=datastring, headers=subgraph['headers'], timeout=20).json()
    numReturns = len(response['data']['parcels'])
    for j in range(numReturns):
        tokenId = response['data']['parcels'][j]['tokenId']
        parcels[tokenId]['district'] = response['data']['parcels'][j]['district']
        parcels[tokenId]['coordinateX'] = response['data']['parcels'][j]['coordinateX']
        parcels[tokenId]['coordinateY'] = response['data']['parcels'][j]['coordinateY']
        parcels[tokenId]['size'] = response['data']['parcels'][j]['size']
        # Subgraph returns the corner coordinates, so we need to add some pixels to get the approximate parcel centers
        if int(parcels[tokenId]['size']) == 0:
            parcels[tokenId]['coordinateX'] = int(parcels[tokenId]['coordinateX']) + 4
            parcels[tokenId]['coordinateY'] = int(parcels[tokenId]['coordinateY']) + 4
        elif int(parcels[tokenId]['size']) == 1:
            parcels[tokenId]['coordinateX'] = int(parcels[tokenId]['coordinateX']) + 8
            parcels[tokenId]['coordinateY'] = int(parcels[tokenId]['coordinateY']) + 8
        elif int(parcels[tokenId]['size']) == 2:
            parcels[tokenId]['coordinateX'] = int(parcels[tokenId]['coordinateX']) + 16
            parcels[tokenId]['coordinateY'] = int(parcels[tokenId]['coordinateY']) + 32
        elif int(parcels[tokenId]['size']) == 3:
            parcels[tokenId]['coordinateX'] = int(parcels[tokenId]['coordinateX']) + 32
            parcels[tokenId]['coordinateY'] = int(parcels[tokenId]['coordinateY']) + 16
        maxTokenId = int(tokenId)
        ind += 1
    time.sleep(2)

# Save everything to file
file1 = open("bids.txt", "w")
for parcel in parcels:
    file1.write(f'{parcels[parcel]["coordinateX"]}, {parcels[parcel]["coordinateY"]}, {int(parcels[parcel]["highestBid"])/1e18}, {parcels[parcel]["parcelSize"]} \n')
file1.close()
