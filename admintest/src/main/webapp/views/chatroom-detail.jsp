<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<script type="text/javascript" src="//dapi.kakao.com/v2/maps/sdk.js?appkey=YOUR_KEY"></script>

<style>
    .chatroom-detail-wrapper {
        max-width: 720px;
        margin: 0 auto;
    }

    .chatroom-detail-card {
        border-radius: 8px;
        border: 1px solid #e2e8f0;
    }

    .chatroom-detail-header {
        background: #2563eb;
        color: #fff;
        padding: 24px;
        border-radius: 8px 8px 0 0;
    }

    .chatroom-detail-header h4 {
        margin: 0;
        font-weight: 600;
        font-size: 20px;
    }

    .chatroom-meta {
        display: flex;
        flex-wrap: wrap;
        gap: 12px 24px;
        margin-top: 12px;
        font-size: 14px;
    }

    .chatroom-meta span {
        display: inline-flex;
        align-items: center;
        gap: 6px;
    }

    .badge-status {
        font-size: 13px;
        padding: 6px 12px;
        border-radius: 4px;
        font-weight: 500;
    }

    #admin-connection-status {
        font-weight: 600;
    }

    #admin-message-log {
        height: 320px;
        overflow-y: auto;
        background: #f8fafc;
        border: 1px solid #e2e8f0;
        border-radius: 6px;
        padding: 16px;
        margin-bottom: 16px;
    }

    .message-entry {
        margin-bottom: 14px;
        line-height: 1.5;
    }

    .message-entry .sender {
        font-weight: 600;
        color: #2563eb;
        font-size: 13px;
    }

    .message-entry .sender.customer {
        color: #0ea5e9;
    }

    .message-entry time {
        display: block;
        font-size: 12px;
        color: #94a3b8;
        margin-top: 4px;
    }

    .message-input-group {
        display: flex;
        gap: 12px;
    }

    .message-input-group input {
        flex: 1;
        border-radius: 6px;
        border: 1px solid #e2e8f0;
        padding: 12px;
        font-size: 14px;
    }

    .message-input-group input:focus {
        outline: none;
        border-color: #2563eb;
    }

    .message-input-group button {
        padding: 0 24px;
        border-radius: 6px;
    }

    .assign-alert {
        margin-top: 16px;
    }

    .video-modal {
        display: none;
        position: fixed;
        z-index: 9999;
        left: 0;
        top: 0;
        width: 100%;
        height: 100%;
        background-color: rgba(0, 0, 0, 0.85);
    }

    .video-modal-content {
        position: relative;
        background-color: #1e293b;
        margin: 2% auto;
        padding: 0;
        width: 90%;
        max-width: 1200px;
        height: 90%;
        border-radius: 12px;
        display: flex;
        flex-direction: column;
    }

    .video-modal-header {
        background: #334155;
        color: white;
        padding: 20px;
        border-radius: 12px 12px 0 0;
        display: flex;
        justify-content: space-between;
        align-items: center;
    }

    .video-modal-header h3 {
        margin: 0;
        font-size: 18px;
        font-weight: 600;
    }

    .video-modal-close {
        color: white;
        font-size: 28px;
        font-weight: normal;
        cursor: pointer;
        background: none;
        border: none;
        padding: 0;
        width: 36px;
        height: 36px;
        display: flex;
        align-items: center;
        justify-content: center;
        border-radius: 6px;
        transition: background-color 0.2s;
    }

    .video-modal-close:hover {
        background-color: rgba(255, 255, 255, 0.1);
    }

    .video-modal-body {
        flex: 1;
        padding: 20px;
        display: flex;
        flex-direction: column;
        gap: 20px;
    }

    .video-container {
        display: grid;
        grid-template-columns: 1fr 1fr;
        gap: 20px;
        flex: 1;
    }

    .video-wrapper {
        position: relative;
        background: #0f172a;
        border-radius: 8px;
        overflow: hidden;
        display: flex;
        align-items: center;
        justify-content: center;
    }

    .video-stream {
        width: 100%;
        height: 100%;
        object-fit: cover;
    }

    .video-label {
        position: absolute;
        top: 12px;
        left: 12px;
        background: rgba(0, 0, 0, 0.6);
        color: white;
        padding: 6px 12px;
        border-radius: 4px;
        font-size: 13px;
        font-weight: 500;
    }

    .video-controls {
        display: flex;
        justify-content: center;
        gap: 15px;
        padding: 15px;
        background: #334155;
        border-radius: 8px;
    }

    .video-control-btn {
        padding: 12px 24px;
        border: none;
        border-radius: 6px;
        font-size: 15px;
        font-weight: 500;
        cursor: pointer;
        transition: all 0.2s;
        display: flex;
        align-items: center;
        gap: 8px;
        background: #dc2626;
        color: white;
    }

    .video-control-btn:hover {
        background: #b91c1c;
    }

    .connection-status {
        text-align: center;
        padding: 10px;
        background: #334155;
        border-radius: 6px;
        color: #e2e8f0;
        font-size: 14px;
    }

    .connection-status.connected {
        background: #10b981;
        color: white;
    }

    .connection-status.disconnected {
        background: #64748b;
        color: white;
    }

    .connection-status.connecting {
        background: #f59e0b;
        color: white;
    }
</style>

<script>
    const adminChatDetail = {
        roomId: '${roomId}',
        custId: '${custId}',
        adminId: '${sessionScope.admin}',
        stompClient: null,
        isConnected: false,
        assignCompleted: false,
        map: null,
        customerMarker: null,
        rtcConnection: null,
        rtcSocket: null,
        localStream: null,

        init() {
            this.cacheElements();
            this.bindEvents();
            this.renderInitialInfo();

            this.waitForKakao(() => {
                this.initMap();
            });

            if (!this.adminId) {
                this.appendSystemMessage('관리자 로그인이 필요합니다.');
                this.disableInputs(true);
                return;
            }

            this.assignRoom();
            this.connectWebSocket();
        },

        waitForKakao(callback) {
            if (typeof kakao !== 'undefined' && kakao.maps) {
                callback();
            } else {
                setTimeout(() => this.waitForKakao(callback), 100);
            }
        },

        initMap: function() {
            const container = document.getElementById('customer-map');
            if (!container) {
                console.error('❌ 지도 컨테이너를 찾을 수 없습니다.');
                return;
            }

            const options = {
                center: new kakao.maps.LatLng(37.5665, 126.9780),
                level: 3
            };

            this.map = new kakao.maps.Map(container, options);

            this.customerMarker = new kakao.maps.Marker({
                map: this.map
            });

            console.log('✅ Kakao Map 초기화 완료');
            this.loadCustomerLocation();
        },

        loadCustomerLocation: function() {
            $.ajax({
                url: 'https://10.20.33.248:8443/api/chatroom/' + this.roomId,
                type: 'GET',
                success: (room) => {
                    if (room.latitude && room.longitude) {
                        this.updateMapLocation(room.latitude, room.longitude);
                    } else {
                        console.log('ℹ️ 고객 위치 정보 없음');
                    }
                },
                error: (xhr) => {
                    console.error('❌ 채팅방 정보 조회 실패:', xhr.responseText);
                }
            });
        },

        updateMapLocation: function(lat, lng) {
            if (!this.map || !this.customerMarker) {
                console.warn('⚠️ 지도가 아직 초기화되지 않았습니다.');
                return;
            }

            const position = new kakao.maps.LatLng(lat, lng);
            this.map.setCenter(position);
            this.customerMarker.setPosition(position);

            $('#map-latitude').text(lat.toFixed(6));
            $('#map-longitude').text(lng.toFixed(6));

            console.log('📍 고객 위치 업데이트:', lat, lng);
        },

        cacheElements() {
            this.$log = $('#admin-message-log');
            this.$messageInput = $('#admin-chat-message');
            this.$sendBtn = $('#admin-send-btn');
            this.$closeBtn = $('#close-chat-btn');
            this.$videoCallBtn = $('#videoCallBtn');
            this.$connection = $('#admin-connection-status');
            this.$assignStatus = $('#assign-status');
        },

        bindEvents: function() {
            this.$sendBtn.on('click', () => this.sendMessage());
            this.$messageInput.on('keypress', (e) => {
                if (e.which === 13) this.sendMessage();
            });
            this.$closeBtn.on('click', () => this.closeChat());

            // ⭐ 영상통화 버튼 - 바로 시작
            this.$videoCallBtn.on('click', () => this.startVideoCall());

            // ⭐ 모달 관련
            $('#closeVideoModal').on('click', () => this.closeVideoModal());
            $('#adminEndCallBtn').on('click', () => this.endAdminVideoCall());
        },

        renderInitialInfo() {
            $('#detail-room-id').text(this.roomId);
            $('#detail-cust-id').text(this.custId);
            $('#detail-admin-id').text(this.adminId || '-');
        },

        assignRoom() {
            const adminId = this.adminId;
            if (!adminId) {
                return;
            }
            $.ajax({
                url: 'https://10.20.33.248:8443/api/chatroom/' + this.roomId + '/assign',
                type: 'POST',
                data: { adminId },
                success: (response) => {
                    this.assignCompleted = true;
                    $('#detail-admin-id').text(adminId);
                    this.$assignStatus
                            .removeClass('badge-secondary badge-danger')
                            .addClass('badge-success')
                            .text('상담 진행 중');
                    this.appendSystemMessage('채팅방이 배정되었습니다. 고객과의 상담을 시작하세요.');
                    this.disableInputs(!(this.isConnected && this.assignCompleted));
                },
                error: (xhr) => {
                    let message = '채팅방 배정에 실패했습니다.';
                    if (xhr.status === 409) {
                        message = '이미 다른 관리자가 배정된 채팅방입니다.';
                        this.fetchRoomInfo();
                    }
                    this.$assignStatus
                            .removeClass('badge-success badge-secondary')
                            .addClass('badge-danger')
                            .text('배정 실패');
                    this.appendSystemMessage(message);
                    this.disableInputs(true);
                }
            });
        },

        fetchRoomInfo() {
            $.ajax({
                url: 'https://10.20.33.248:8443/api/chatroom/active/' + this.custId,
                type: 'GET',
                dataType: 'json',
                success: (data) => {
                    if (data && data.adminId) {
                        $('#detail-admin-id').text(data.adminId);
                        this.appendSystemMessage('현재 상담사는 ' + data.adminId + ' 입니다.');
                        if (data.adminId === this.adminId) {
                            this.assignCompleted = true;
                            this.$assignStatus
                                    .removeClass('badge-secondary badge-danger')
                                    .addClass('badge-success')
                                    .text('상담 진행 중');
                            this.disableInputs(!(this.isConnected && this.assignCompleted));
                        }
                    }
                }
            });
        },

        connectWebSocket() {
            if (!this.adminId) {
                return;
            }
            const socket = new SockJS('${wsurl}adminchat');
            this.stompClient = Stomp.over(socket);
            this.$connection.text('연결 중...').removeClass('text-danger').addClass('text-warning');
            this.stompClient.connect({}, (frame) => {
                console.log('Admin connected:', frame);
                this.isConnected = true;
                this.$connection.text('연결 완료').removeClass('text-warning text-danger').addClass('text-success');
                this.disableInputs(!(this.assignCompleted));
                this.appendSystemMessage('WebSocket 연결이 완료되었습니다.');

                // ⭐ 일반 채팅 + 영상통화 신호 수신
                this.stompClient.subscribe('/send/to/' + this.adminId, (msg) => {
                    try {
                        const payload = JSON.parse(msg.body);

                        if (payload.content1 === '__VIDEO_CALL_START__') {
                            // ⭐ User가 영상통화 시작 신호를 보냄
                            console.log('📞 User가 영상통화를 시작했습니다!');
                            this.receiveVideoCallStart();
                        } else {
                            this.appendMessage(payload.sendid || '고객', payload.content1, 'customer');
                        }
                    } catch (error) {
                        console.error('메시지 파싱 오류', error);
                    }
                });
            }, () => {
                this.isConnected = false;
                this.$connection.text('연결 실패').removeClass('text-warning text-success').addClass('text-danger');
                this.disableInputs(true);
                this.stompClient = null;
            });

            socket.onclose = () => {
                this.isConnected = false;
                this.$connection.text('연결 종료').removeClass('text-success text-warning').addClass('text-danger');
                this.disableInputs(true);
                this.stompClient = null;
                this.appendSystemMessage('WebSocket 연결이 종료되었습니다. 새로고침 후 다시 시도해주세요.');
            };
        },

        disableInputs(disabled) {
            this.$messageInput.prop('disabled', disabled);
            this.$sendBtn.prop('disabled', disabled);
            this.$closeBtn.prop('disabled', disabled);
            this.$videoCallBtn.prop('disabled', disabled);
        },

        closeChat() {
            if (!confirm('상담을 종료하시겠습니까?\n종료 후에는 다시 시작할 수 없습니다.')) {
                return;
            }

            $.ajax({
                url: 'https://10.20.33.248:8443/api/chatroom/' + this.roomId + '/close',
                type: 'POST',
                success: (response) => {
                    this.appendSystemMessage('✅ 상담이 종료되었습니다.');
                    this.$assignStatus
                            .removeClass('badge-success badge-secondary badge-danger')
                            .addClass('badge-dark')
                            .text('종료됨');
                    this.disableInputs(true);

                    if (this.stompClient && this.isConnected) {
                        const closePayload = {
                            sendid: this.adminId,
                            receiveid: this.custId,
                            content1: '__CHAT_CLOSED__',
                            type: 'SYSTEM_CLOSE'
                        };
                        this.stompClient.send('/adminreceiveto', {}, JSON.stringify(closePayload));
                    }

                    setTimeout(() => {
                        window.location.href = '/chatroom';
                    }, 3000);
                },
                error: (xhr) => {
                    alert('채팅방 종료에 실패했습니다: ' + xhr.responseText);
                }
            });
        },

        sendMessage() {
            if (!this.stompClient || !this.isConnected || !this.assignCompleted) {
                alert('WebSocket 연결 또는 채팅방 배정이 완료되지 않았습니다.');
                return;
            }
            const message = this.$messageInput.val().trim();
            if (!message) {
                return;
            }
            const payload = {
                sendid: this.adminId,
                receiveid: this.custId,
                content1: message,
                roomId: this.roomId
            };
            this.stompClient.send('/adminreceiveto', {}, JSON.stringify(payload));
            this.appendMessage('나', message, 'admin');
            this.$messageInput.val('');
            this.$messageInput.focus();
        },

        appendMessage(sender, message, type) {
            const sanitized = $('<div>').text(message).html();
            const time = new Date().toLocaleTimeString('ko-KR', { hour12: false });
            const entry = [
                '<div class="message-entry">',
                '<div class="sender ' + (type || 'admin') + '">[' + time + '] ' + sender + '</div>',
                '<div class="body">' + sanitized + '</div>',
                '</div>'
            ].join('');
            this.$log.append(entry);
            this.$log.scrollTop(this.$log[0].scrollHeight);
        },

        appendSystemMessage(message) {
            const time = new Date().toLocaleTimeString('ko-KR', { hour12: false });
            this.$log.append(
                    '<div class="message-entry">' +
                    '<div class="sender">[' + time + '] 시스템</div>' +
                    '<div class="body">' + $('<div>').text(message).html() + '</div>' +
                    '</div>'
            );
            this.$log.scrollTop(this.$log[0].scrollHeight);
        },

        // ⭐ Admin이 영상통화 시작 (User에게 알림 전송)
        startVideoCall: function() {
            if (!this.assignCompleted) {
                alert('먼저 채팅방에 배정되어야 합니다.');
                return;
            }

            console.log('📞 Admin이 영상통화를 시작합니다...');

            // ⭐ User에게 영상통화 시작 신호 전송
            if (this.stompClient && this.isConnected) {
                const payload = {
                    sendid: this.adminId,
                    receiveid: this.custId,
                    content1: '__VIDEO_CALL_START__',
                    roomId: this.roomId
                };
                this.stompClient.send('/adminreceiveto', {}, JSON.stringify(payload));
            }

            // 모달 열고 자동으로 통화 시작
            $('#videoModal').fadeIn(300);
            this.initializeVideoCall();
        },

        // ⭐ User가 영상통화를 시작했을 때 (수신)
        receiveVideoCallStart: function() {
            console.log('📞 User의 영상통화 요청을 받았습니다!');

            // 모달 자동 열림
            $('#videoModal').fadeIn(300);

            // 자동으로 통화 시작
            this.initializeVideoCall();
        },

        // ⭐ 실제 영상통화 초기화 (WebRTC)
        initializeVideoCall: function() {
            $('#adminVideoConnectionStatus').removeClass('disconnected').addClass('connecting').text('연결 중...');

            navigator.mediaDevices.getUserMedia({ video: true, audio: true })
                    .then((stream) => {
                        this.localStream = stream;
                        document.getElementById('adminLocalVideo').srcObject = stream;
                        this.setupAdminWebRTC();
                    })
                    .catch((error) => {
                        console.error('❌ Admin 미디어 접근 실패:', error);
                        alert('카메라/마이크 접근 권한이 필요합니다.');
                        $('#adminVideoConnectionStatus').removeClass('connecting').addClass('disconnected').text('연결 실패');
                    });
        },

        setupAdminWebRTC: function() {
            this.rtcSocket = new WebSocket('wss://10.20.33.248:8443/signal');

            this.rtcSocket.onopen = () => {
                console.log('✅ Admin Signaling Server 연결');

                this.rtcSocket.send(JSON.stringify({
                    type: 'join',
                    roomId: this.roomId.toString(),
                    userId: this.adminId
                }));
            };

            this.rtcSocket.onmessage = (event) => {
                const message = JSON.parse(event.data);
                this.handleAdminSignalingMessage(message);
            };

            this.rtcSocket.onerror = (error) => {
                console.error('❌ Admin Signaling 오류:', error);
                $('#adminVideoConnectionStatus').removeClass('connecting').addClass('disconnected').text('연결 실패');
            };

            this.rtcSocket.onclose = (event) => {
                console.log('ℹ️ Admin Signaling WebSocket 연결 종료');
            };

            const configuration = {
                iceServers: [{ urls: 'stun:stun.l.google.com:19302' }]
            };

            this.rtcConnection = new RTCPeerConnection(configuration);

            this.localStream.getTracks().forEach(track => {
                this.rtcConnection.addTrack(track, this.localStream);
            });

            this.rtcConnection.onconnectionstatechange = () => {
                console.log('🔄 Admin RTC 연결 상태:', this.rtcConnection.connectionState);

                switch (this.rtcConnection.connectionState) {
                    case 'connected':
                        $('#adminVideoConnectionStatus').removeClass('connecting disconnected').addClass('connected').text('통화 연결됨');
                        break;
                    case 'disconnected':
                        $('#adminVideoConnectionStatus').removeClass('connecting connected').addClass('disconnected').text('연결 끊김');
                        break;
                    case 'failed':
                        $('#adminVideoConnectionStatus').removeClass('connecting connected').addClass('disconnected').text('연결 실패');
                        break;
                    case 'closed':
                        $('#adminVideoConnectionStatus').removeClass('connecting connected').addClass('disconnected').text('연결 종료됨');
                        break;
                }
            };

            this.rtcConnection.ontrack = (event) => {
                console.log('📹 Admin 원격 스트림 수신');
                const remoteVideo = document.getElementById('adminRemoteVideo');
                remoteVideo.srcObject = event.streams[0];
                remoteVideo.play().catch(err => console.warn('⚠️ 원격 영상 자동재생 실패:', err));
            };

            this.rtcConnection.onicecandidate = (event) => {
                if (event.candidate && this.rtcSocket && this.rtcSocket.readyState === WebSocket.OPEN) {
                    this.rtcSocket.send(JSON.stringify({
                        type: 'ice-candidate',
                        roomId: this.roomId.toString(),
                        data: event.candidate
                    }));
                }
            };
        },

        handleAdminSignalingMessage: function(message) {
            console.log('📨 Admin Signaling 메시지:', message.type);

            switch (message.type) {
                case 'user-joined':
                    // User가 나중에 들어왔을 때 Admin이 Offer 생성
                    this.rtcConnection.createOffer()
                            .then(offer => this.rtcConnection.setLocalDescription(offer))
                            .then(() => {
                                this.rtcSocket.send(JSON.stringify({
                                    type: 'offer',
                                    roomId: this.roomId.toString(),
                                    data: this.rtcConnection.localDescription
                                }));
                            });
                    break;

                case 'offer':
                    const offer = message.offer || message.data;
                    if (!offer) return;

                    this.rtcConnection.setRemoteDescription(new RTCSessionDescription(offer))
                            .then(() => this.rtcConnection.createAnswer())
                            .then(answer => this.rtcConnection.setLocalDescription(answer))
                            .then(() => {
                                this.rtcSocket.send(JSON.stringify({
                                    type: 'answer',
                                    roomId: this.roomId.toString(),
                                    data: this.rtcConnection.localDescription
                                }));
                            });
                    break;

                case 'answer':
                    const answer = message.answer || message.data;
                    if (!answer) return;

                    this.rtcConnection.setRemoteDescription(new RTCSessionDescription(answer));
                    break;

                case 'ice-candidate':
                    const candidate = message.candidate || message.data;
                    if (!candidate) return;

                    this.rtcConnection.addIceCandidate(new RTCIceCandidate(candidate));
                    break;
            }
        },

        closeVideoModal: function() {
            if (confirm('통화를 종료하시겠습니까?')) {
                this.endAdminVideoCall();
                $('#videoModal').fadeOut(300);
            }
        },

        endAdminVideoCall: function() {
            console.log('📴 Admin 영상통화 종료');

            if (this.localStream) {
                this.localStream.getTracks().forEach(track => track.stop());
                this.localStream = null;
            }

            if (this.rtcConnection) {
                this.rtcConnection.close();
                this.rtcConnection = null;
            }

            if (this.rtcSocket) {
                this.rtcSocket.close();
                this.rtcSocket = null;
            }

            document.getElementById('adminLocalVideo').srcObject = null;
            document.getElementById('adminRemoteVideo').srcObject = null;
            $('#adminVideoConnectionStatus').removeClass('connected connecting').addClass('disconnected').text('연결 대기 중');
        }
    };

    $(function() {
        adminChatDetail.init();
    });
</script>

<div class="chatroom-detail-wrapper">
    <div class="card chatroom-detail-card">
        <div class="chatroom-detail-header">
            <h4>실시간 상담</h4>
            <div class="chatroom-meta">
                <span><i class="fas fa-hashtag"></i> 방 번호: <strong id="detail-room-id"></strong></span>
                <span><i class="fas fa-user"></i> 고객 ID: <strong id="detail-cust-id"></strong></span>
                <span><i class="fas fa-user-shield"></i> 담당자: <strong id="detail-admin-id"></strong></span>
                <span class="badge badge-secondary badge-status" id="assign-status">배정 중...</span>
            </div>
        </div>
        <div class="card-body">
            <div class="card mb-3">
                <div class="card-header bg-info text-white">
                    <i class="fas fa-map-marker-alt"></i> 고객 위치 정보
                </div>
                <div class="card-body p-0">
                    <div id="customer-map" style="width:100%; height:300px;"></div>
                    <div class="p-3">
                        <small class="text-muted">
                            <i class="fas fa-info-circle"></i>
                            위도: <span id="map-latitude">-</span>,
                            경도: <span id="map-longitude">-</span>
                        </small>
                    </div>
                </div>
            </div>

            <div class="d-flex justify-content-between align-items-center mb-3">
                <div>
                    <span class="text-muted">WebSocket 상태:</span>
                    <span id="admin-connection-status" class="text-danger">연결 대기</span>
                </div>
                <div class="text-muted">고객에게서 온 메시지는 아래에 표시됩니다.</div>
            </div>

            <div id="admin-message-log"></div>

            <div class="d-flex justify-content-end mb-3">
                <button id="videoCallBtn" class="btn btn-success btn-sm mr-2" disabled>
                    <i class="fas fa-video"></i> 영상 통화
                </button>
                <button id="close-chat-btn" class="btn btn-danger btn-sm" disabled>
                    <i class="fas fa-times-circle"></i> 상담 종료
                </button>
            </div>

            <!-- 영상통화 모달 -->
            <div id="videoModal" class="video-modal">
                <div class="video-modal-content">
                    <div class="video-modal-header">
                        <h3><i class="fas fa-video"></i> 영상 상담 (Admin)</h3>
                        <button class="video-modal-close" id="closeVideoModal">×</button>
                    </div>
                    <div class="video-modal-body">
                        <div class="video-container">
                            <div class="video-wrapper">
                                <video id="adminLocalVideo" autoplay playsinline muted class="video-stream"></video>
                                <div class="video-label">내 화면 (Admin)</div>
                            </div>
                            <div class="video-wrapper">
                                <video id="adminRemoteVideo" autoplay playsinline class="video-stream"></video>
                                <div class="video-label">고객 화면</div>
                            </div>
                        </div>
                        <div class="video-controls">
                            <button id="adminEndCallBtn" class="video-control-btn">
                                <i class="fas fa-phone-slash"></i> 통화 종료
                            </button>
                        </div>
                        <div id="adminVideoConnectionStatus" class="connection-status disconnected">
                            연결 대기 중
                        </div>
                    </div>
                </div>
            </div>
            <div class="message-input-group">
                <input type="text" id="admin-chat-message" placeholder="메시지를 입력하세요" disabled>
                <button id="admin-send-btn" class="btn btn-primary" disabled>전송</button>
            </div>

            <div class="alert alert-info assign-alert" role="alert">
                채팅방에 입장하면 자동으로 상담사로 배정되며, 고객과의 메시지가 실시간으로 표시됩니다.
            </div>
        </div>
    </div>
</div>
